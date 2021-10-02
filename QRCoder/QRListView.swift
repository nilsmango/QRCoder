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
    @State private var newCodeData = QRCode.Data()
    
    let saveAction: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                ButtonView {
                    isPresented = true
                } content: {
                    Label("New QR Code", systemImage: "qrcode")
                }
                .padding()
                
                ZStack {
                    List {
                        ForEach(myData.codes) { qrData in
                            NavigationLink(destination: DetailView(myData: myData, qrData: qrData)) {
                                VStack {
                                    QRCodeView(qrString: qrData.qrString)
                                    Text(qrData.title)
                                        .font(.headline)
                                }
                                
                            }
                        }
                        .onDelete { indexSet in
                            myData.delete(at: indexSet)
                        }
                        .onMove { indexSet, newPlace in
                            myData.move(from: indexSet, to: newPlace)
                        }
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
            .navigationTitle("QRCoder")
            .toolbar {
                EditButton()
            }
            .fullScreenCover(isPresented: $isPresented, content: {
                NavigationView {
                    EditView(codeData: $newCodeData)
                        .navigationTitle("New QR Code")
                        .navigationBarItems(leading: Button(action: {
                            isPresented = false
                        }, label: {
                            Text("Dismiss")
                        }), trailing: Button(action: {
                            isPresented = false
                            let newCode = QRCode(title: newCodeData.title, qrCodeType: newCodeData.qrCodeType, complexContact: newCodeData.complexContact,  hiddenNetwork: newCodeData.hiddenNetwork, text: newCodeData.text, firstName: newCodeData.firstName, lastName: newCodeData.lastName, email: newCodeData.email, phoneNumber: newCodeData.phoneNumber, workNumber: newCodeData.workNumber, address: newCodeData.address, url: newCodeData.url, network: newCodeData.network, password: newCodeData.password, encryptionType: newCodeData.encryptionType)
                            myData.codes.append(newCode)
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
                if phase == .inactive { saveAction() }
            }
        }
    }
}

struct QRListView_Previews: PreviewProvider {
    static var previews: some View {
        QRListView(myData: QRData(), saveAction: {})
//                    .preferredColorScheme(.dark)
    }
    
    
}
