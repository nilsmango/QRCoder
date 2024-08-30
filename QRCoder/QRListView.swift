//
//  QRListView.swift
//  QRCoder
//
//  Created by Simon Lang on 01.10.21.
//

import SwiftUI

struct QRListView: View {
    
    @ObservedObject var myData: QRData
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isPresented = false
    @State private var newCodeData = QRCode.Datas()
    @State private var editMode: EditMode = .inactive
    @State private var presentOptions = false
    @State private var appearedOnce = false
    
    @AppStorage("created") var qrCodesCreated = 0
    
    let saveAction: () -> Void
    
    var watchConnection = WatchConnection()
    
    
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
        NavigationView {
            VStack {
                // TODO: add here "and not full version"
                if myData.codes.count < 1 || UserDefaults.standard.bool(forKey: "*ID of IAP Product*") {
                    ButtonView {
                        isPresented = true
                    } content: {
                        Label("New QR Code", systemImage: "qrcode")
                    }
                    .padding()
                } else {
                    ButtonView {
                        // open in app purchase
                    } content: {
                        Label("Get full version", systemImage: "qrcode")
                    }
                    .padding(.top)
                    
                    Text("The free version of QRCoder is limited to one QR code at a time. Buy the full version with unlimited QR codes for 1 $. \n→ Restore a purchase by tapping on the \"i\" in the top right corner.")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                        .padding([.leading, .trailing], 40.0)
                        .padding([.bottom, .top])
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
                            updateCompleteQRList()
                        }
                        .onMove { indexSet, newPlace in
                            myData.move(from: indexSet, to: newPlace)
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
            .navigationTitle("QR Coder")
            .toolbar {
                if myData.codes.count > 0 {
                    EditButton()
                }
                Button(action: { presentOptions = true }) { Label("Options", systemImage: "info.circle")}
            }
            .environment(\.editMode, $editMode)
            .fullScreenCover(isPresented: $presentOptions, content: {
                NavigationView {
                    OptionView(qrCodesCreated: qrCodesCreated)
                        .navigationTitle("Info")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Dismiss") {
                                    presentOptions = false
                                }
                            }
                        }
                }
            }
            
            )
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
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    saveAction()
                }
            }
            .onAppear() {
                if appearedOnce == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        updateCompleteQRList()
                    }
                }
                
            }
        }
    }
}

struct QRListView_Previews: PreviewProvider {
    static var previews: some View {
        QRListView(myData: QRData(), saveAction: {})
        
        QRListView(myData: QRData(), saveAction: {})
            .preferredColorScheme(.dark)
    }
    
    
}
