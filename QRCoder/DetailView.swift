//
//  DetailView.swift
//  QRCoder
//
//  Created by Simon Lang on 01.10.21.
//

import SwiftUI

struct DetailView: View {
    
    @ObservedObject var myData: QRData
    
    var qrData: QRCode
    
    @State private var data: QRCode.Datas = QRCode.Datas()
    @State private var editViewIsPresented = false
    @State private var shareSheetPresented = false
    @State private var items: [Any] = []
    
    var watchConnection: WatchConnection
    
    private func updateWatchList() {
        var codesDictionary: [String : Any] = [:]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
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
            
            watchConnection.session.sendMessage(codesDictionary, replyHandler: nil)
        }
    }
    
    var qrView: some View {
        QRCodeView(qrString: qrData.qrString)
            .padding(.bottom, 40)
            .padding(.horizontal, 15)
            .frame(width: 1000, height: 1000, alignment: .center)
            

    }
    
    var body: some View {
        VStack {
            QRCodeView(qrString: qrData.qrString)
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
                items.removeAll()
                items.append(qrImage)
                shareSheetPresented = true
            } content: {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            ButtonView {
                guard let index = myData.codes.firstIndex(where: { $0.id == qrData.id }) else {
                    fatalError("couldn't find the index for data")
                }

                myData.codes.remove(at: index)
                
                updateWatchList()
                
            } content: {
                Label("Delete", systemImage: "trash")
//                    .foregroundColor(.red)
            }
            .padding(10)
            
            Spacer()

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
                        
                        updateWatchList()
                    })
            }
        }
        .sheet(isPresented: $shareSheetPresented, content: {
            ShareSheet(items: items)
        })
        
        
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(myData: QRData(), qrData: QRCode.sampleData[0], watchConnection: WatchConnection())
        }
        
    }
}
