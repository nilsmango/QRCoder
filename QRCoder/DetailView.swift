//
//  DetailView.swift
//  QRCoder
//
//  Created by Simon Lang on 01.10.21.
//

import SwiftUI

struct DetailView: View {
    
    @ObservedObject var myData: QRData
    @Environment(\.presentationMode) var presentationMode

    var qrData: QRCode
    
    @State private var data: QRCode.Datas = QRCode.Datas()
    @State private var editViewIsPresented = false
    @State private var isDeleted = false
    
    var watchConnection: WatchConnection
    
    private func updateWatchList() {
        
        if watchConnection.session.activationState == .activated {
            var codesDictionary: [String : Any] = [:]
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
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
            }
        }
        
    }
    
    var qrView: some View {
        QRCodeView(qrString: qrData.qrString)
            .padding(.bottom, 40)
            .padding(.horizontal, 15)
            .frame(width: 1000, height: 1000, alignment: .center)
            

    }
    
    private func makeImage() -> UIImage {
        qrView.snapshot()
    }
    
    var body: some View {
        Group {
            if isDeleted {
                EmptyView()
                    .onChange(of: qrData) { oldValue, newValue in
                        isDeleted = false
                    }
            } else {
                VStack {
                    QRCodeView(qrString: qrData.qrString)
                        .accessibilityLabel("QR code")
                        .padding(10)
                    Spacer()
                    
                    ButtonView {
                        editViewIsPresented = true
                        data = qrData.data
                    } content: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    .padding(10)
                    
                    ButtonView {
                        let qrImage = qrView.snapshot()
                        let AV = UIActivityViewController(activityItems: [qrImage], applicationActivities: nil)
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootViewController = window.rootViewController {
                            
                            // This is crucial for iPad support
                            if let popoverController = AV.popoverPresentationController {
                                popoverController.sourceView = rootViewController.view
                                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                                popoverController.permittedArrowDirections = []
                            }
                            
                            rootViewController.present(AV, animated: true, completion: nil)
                        }
                    } content: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    ButtonView {
                        guard let index = myData.codes.firstIndex(where: { $0.id == qrData.id }) else {
                            fatalError("couldn't find the index for data")
                        }
                        
                        myData.codes.remove(at: index)
                        isDeleted = true
                        presentationMode.wrappedValue.dismiss()
                        myData.save()
                        updateWatchList()
                        
                    } content: {
                        Label("Delete", systemImage: "trash")
                        //                    .tint(.red)
                        //                    .foregroundColor(.red)
                    }
                    .padding(10)
                    
                    Spacer()
                }
            }
        }
        .navigationTitle(qrData.title)
        .fullScreenCover(isPresented: $editViewIsPresented) {
            NavigationView {
                EditView(codeData: $data)
                    .navigationTitle(Text("Edit QR Code"))
                    .navigationBarItems(leading: Button("Cancel") {
                        editViewIsPresented = false
                    }, trailing: Button("Done") {
                        editViewIsPresented = false
                        guard let index = myData.codes.firstIndex(where: { $0.id == qrData.id }) else {
                            fatalError("couldn't find the index for data")
                        }
                        myData.codes[index].update(from: data)
                        myData.save()
                        updateWatchList()
                    })
            }
        }
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(myData: QRData(), qrData: QRCode.sampleData[0], watchConnection: WatchConnection())
        }
        
    }
}
