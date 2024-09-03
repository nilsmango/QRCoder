//
//  QRData.swift
//  QRCoder
//
//  Created by Simon Lang on 30.09.21.
//

import SwiftUI
import WidgetKit
import StoreKit

typealias Transaction = StoreKit.Transaction

public enum StoreError: Error {
    case failedVerification
}


class QRData: ObservableObject {
    
    private static var documentsFolder: URL {
//        do {
//            return try FileManager.default.url(for: .documentDirectory,
//                                                  in: .userDomainMask,
//                                                  appropriateFor: nil,
//                                                  create: false)
//
//            Oben alter weg, unten neue idee
            let appIdentifier = "group.qrcode"
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appIdentifier)!
            
//        } catch {
//            fatalError("Couldn't find documents directory")
//        }
    }
    
    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("qrcoder.data")
    }
    
    @Published var codes: [QRCode] = []
    
    func delete(at indexSet: IndexSet) {
        codes.remove(atOffsets: indexSet)
    }
    
    func move(from offset: IndexSet, to newPlace: Int) {
        codes.move(fromOffsets: offset, toOffset: newPlace)
    }
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                return
            }
            guard let qrCodes = try? JSONDecoder().decode([QRCode].self, from: data) else {
                fatalError("Couldn't decode saved codes data")
            }
            DispatchQueue.main.async {
                self?.codes = qrCodes
                
            }
        }
    }
 
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let codes = self?.codes else { fatalError("Self out of scope!") }
            guard let data = try? JSONEncoder().encode(codes) else { fatalError("Error encoding data") }
            
            do {
                let outFile = Self.fileURL
                try data.write(to: outFile)
                WidgetCenter.shared.reloadAllTimelines()
                
            } catch {
                fatalError("Couldn't write to file")
            }
        }
    }
    
    init() {
        // Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()
        
        Task {
            // During store initialization, request products from the App Store.
            await loadProductIdentifiersAndRequestProducts()
            
            await updateCustomerProductStatus()
        }
    }
        
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - In App Purchases
        
    @AppStorage("Premium") var hasPurchasedPremium = false
    @Published var purchasedProducts = [Product]()
    @Published var premiumProducts: [Product] = []
    @Published var unableToLoadProducts = false
   
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    @MainActor
    func loadProductIdentifiersAndRequestProducts() async {
            guard let url = Bundle.main.url(forResource: "product_ids", withExtension: "plist") else {
                fatalError("Unable to resolve url for in the bundle.")
            }
            do {
                unableToLoadProducts = false
                let data = try Data(contentsOf: url)
                if let productIdentifiers = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] {
                    await requestProducts(productIdentifiers: productIdentifiers)
                }
            } catch {
                unableToLoadProducts = true
                print("\(error.localizedDescription)")
            }
        }
    
    private func requestProducts(productIdentifiers: [String]) async {
        do {
            // Request products from the App Store using the identifiers that the `product_ids.plist` file defines.
            let products = try await Product.products(for: productIdentifiers)
            DispatchQueue.main.async {
                self.premiumProducts = products
            }

        } catch {
            print("Failed product request from the App Store server. \(error)")
            DispatchQueue.main.async {
                self.unableToLoadProducts = true
            }
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification.")
                }
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        
        var currentEntitledPurchases: [Product] = []

        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)

                // Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .nonConsumable:
                    if let premium = premiumProducts.first(where: { $0.id == transaction.productID }) {
                        currentEntitledPurchases.append(premium)
                    }
                case .nonRenewable:
                    // we don't have this in our purchases
                    break
                case .autoRenewable:
                    // we don't have this in our purchases
                    break
                default:
                    break
                }
            } catch {
                print("Something went wrong")
            }
        }
        
        // Update the store information with the purchased products.
        purchasedProducts = currentEntitledPurchases
        hasPurchasedPremium = !currentEntitledPurchases.isEmpty
    }
    
    func purchase(product: Product) async throws -> Transaction? {
        // Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            // Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func createImageForPurchasedProduct(product: Product? = nil) -> Image {
        let id = product?.id ?? purchasedProducts.first?.id
        if id != nil {
            return Image("PremiumTap")
        }
        return Image("NormalTap")
    }
    
    func isWillRenew(product: Product) async -> Bool? {
        guard let SubscriptionGroupStatus = try? await product.subscription?.status.first else {
            print("There is no AutoRenewable Group")
            return nil
        }
        
        guard case .verified(let renewalInfo) = SubscriptionGroupStatus.renewalInfo else {
            print("The App Store could not verify your subscription status.")
            return nil
        }
        return renewalInfo.willAutoRenew
    }
}





