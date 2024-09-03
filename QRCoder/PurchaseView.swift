//
//  PurchaseView.swift
//  QRCoder
//
//  Created by Simon Lang on 03.09.2024.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @ObservedObject var myData: QRData
    
    var body: some View {
        StoreView(ids:  ["com.project7III.qr.full"])
                    .storeButton(.visible, for: .restorePurchases, .redeemCode, .policies)
//                    .subscriptionStorePolicyDestination(for: .privacyPolicy) {
//                        Text("Privacy policy here")
//                    }
//                    .subscriptionStorePolicyDestination(for: .termsOfService) {
//                        Text("Terms of service here")
//                    }
//                    .subscriptionStoreControlStyle(.prominentPicker)
    }
}

#Preview {
    PurchaseView(myData: QRData())
}
