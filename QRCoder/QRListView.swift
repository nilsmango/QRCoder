//
//  QRListView.swift
//  QRCoder
//
//  Created by Simon Lang on 01.10.21.
//

import SwiftUI
import StoreKit

struct QRListView: View {
    
    @ObservedObject var myData: QRData
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isPresented = false
    @State private var newCodeData = QRCode.Datas()
    @State private var editMode: EditMode = .inactive
    @State private var presentOptions = false
    @State private var appearedOnce = false
    @State private var isShowingError = false
    @State private var errorTitle = ""
    @State private var showCodeSheet = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    @AppStorage("created") var qrCodesCreated = 0
        
    var watchConnection = WatchConnection()
    
    @State private var wasPurchased = false
    
    private func updateCompleteQRList() {
        print("Trying to send list")
        if watchConnection.session.activationState == .activated {
            var codesDictionary: [String : Any] = [:]
                for code in myData.codes {
                    // check if code.title already exists and change title if it does; yes only triplets are ok
                    if codesDictionary[code.title] == nil {
                        codesDictionary[code.title] = code.qrImage
                    } else if codesDictionary[code.title + " 2"] == nil {
                        codesDictionary[code.title + " 2"] = code.qrImage
                    } else {
                        codesDictionary[code.title + " 3"] = code.qrImage
                    }
                    
                }
                
                watchConnection.session.transferUserInfo(codesDictionary)
                
                appearedOnce = true
        }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                // TODO: add here "or has purchased full version"
                if myData.codes.count < 1 || wasPurchased || myData.hasPurchasedPremium {
                    ButtonView {
                        isPresented = true
                    } content: {
                        Label("New QR Code", systemImage: "qrcode")
                    }
                    .padding()
                } else {
                    if let premium = myData.premiumProducts.first(where: { $0.id == "com.project7III.qr.full"}) {

                        Text("The free version of QRCoder is limited to one QR code at a time.\nEdit or remove your QR code below or unlock the full version with **unlimited QR codes for only \(premium.displayPrice)**.")
                            .foregroundColor(.primary.opacity(0.9))
                            .padding([.leading, .trailing], 40.0)
                            .padding(.top)
                        
                        ButtonView {
                            Task {
                                await buy(product: premium)
                            }
                        } content: {
                            Label("Get Full Version", systemImage: "qrcode")
                        }
                        .padding([.bottom, .top])
                        
                        Button {
                            showCodeSheet = true
                        } label: {
                            Text("Redeem Code")
                                .fontWeight(.semibold)
                                .font(.callout)
                        }
                        .padding(.bottom)
                        
                    } else {
                        Text("Could not load available upgrades, please try again when connected to the internet.\nThe free version of QRCoder is limited to one QR code at a time. Edit or remove your QR code below.")
                    }
                }
                
                ZStack {
                    List {
                        ForEach(myData.codes) { qrData in
                            NavigationLink(destination: DetailView(myData: myData, qrData: qrData, watchConnection: watchConnection)) {
                                VStack {
                                    QRCodeView(qrString: qrData.qrString).accessibilityLabel("QR code")
                                    Text(qrData.title)
                                        .accessibilityLabel("QR code title")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            myData.delete(at: indexSet)
                            myData.save()
                            updateCompleteQRList()
                        }
                        .onMove { indexSet, newPlace in
                            myData.move(from: indexSet, to: newPlace)
                            myData.save()
                        }
                        
                    }
                    .refreshable() {
                        updateCompleteQRList()
                    }
                    if myData.codes.isEmpty {
                        VStack {
                            Text("- Wow, such empty -")
                            Text("Tap on New QR Code to start.")
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("7III QR")
            .toolbar {
                if myData.codes.count > 0 {
                    EditButton()
                }
                Button(action: { presentOptions = true }) { Label("Options", systemImage: "info.circle")}
            }
            .environment(\.editMode, $editMode)
            .fullScreenCover(isPresented: $presentOptions, content: {
                NavigationView {
                    OptionView(myData: myData, qrCodesCreated: qrCodesCreated)
                        .navigationTitle("Info & Help")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Dismiss") {
                                    presentOptions = false
                                }
                            }
                        }
                }
            })
            .fullScreenCover(isPresented: $isPresented, content: {
                NavigationView {
                    EditView(codeData: $newCodeData)
                        .navigationTitle("New QR Code")
                        .navigationBarItems(leading: Button(action: {
                            isPresented = false
                        }, label: {
                            Text("Cancel")
                        }), trailing: Button(action: {
                            isPresented = false
                            let newCode = QRCode(title: newCodeData.title, qrCodeType: newCodeData.qrCodeType, complexContact: newCodeData.complexContact,  hiddenNetwork: newCodeData.hiddenNetwork, text: newCodeData.text, firstName: newCodeData.firstName, lastName: newCodeData.lastName, email: newCodeData.email, phoneNumber: newCodeData.phoneNumber, workNumber: newCodeData.workNumber, address: newCodeData.address, url: newCodeData.url, network: newCodeData.network, password: newCodeData.password, encryptionType: newCodeData.encryptionType, qrImage: generateQRCode(from: stringFromQRData(codeData: newCodeData)).pngData())
                            
                            myData.codes.append(newCode)
                            
                            qrCodesCreated += 1
                            myData.save()
                            // send the new qrCode to the apple watch
                            updateCompleteQRList()
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                newCodeData.title = ""
                                newCodeData.qrCodeType = "Text"
                                newCodeData.complexContact = false
                                newCodeData.hiddenNetwork = false
                                newCodeData.text = ""
                                newCodeData.firstName = ""
                                newCodeData.lastName = ""
                                newCodeData.email = ""
                                newCodeData.phoneNumber = ""
                                newCodeData.workNumber = ""
                                newCodeData.address = ""
                                newCodeData.url = "http://"
                                newCodeData.network = ""
                                newCodeData.password = ""
                                newCodeData.encryptionType = "WPA/WPA2"
                            }
                        }, label: {
                            Text("Save")
                        }))
                }
            })
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
            })
            
            .offerCodeRedemption(isPresented: $showCodeSheet, onCompletion: { result in
                switch result {
                case .success:
                    if myData.hasPurchasedPremium {
                        wasPurchased = true
                    }
                case .failure(let error):
                    print("Code redemption failed: \(error.localizedDescription)")
                }
            })
            
            .onAppear() {
                if appearedOnce == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        updateCompleteQRList()
                    }
                }
                
            }
        } detail: {
            
        }
        .navigationSplitViewStyle(.automatic)
    }
    
    func buy(product: Product) async {
        do {
            if try await myData.purchase(product: product) != nil {
                wasPurchased = true
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(product.id). \(error)")
        }
    }
}

struct QRListView_Previews: PreviewProvider {
    static var previews: some View {
        QRListView(myData: QRData())
        
        QRListView(myData: QRData())
            .preferredColorScheme(.dark)
    }
    
    
}
