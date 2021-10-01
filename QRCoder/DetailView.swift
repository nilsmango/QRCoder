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
    
    @State private var data: QRCode.Data = QRCode.Data()
    @State private var editViewIsPresented = false

    
    var body: some View {
        VStack {
            QRCodeView(qrString: qrData.title)
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
                guard let index = myData.codes.firstIndex(where: { $0.id == qrData.id }) else {
                    fatalError("couldn't find the index for data")
                }
                myData.codes.remove(at: index)
            } content: {
                Label("Delete", systemImage: "trash")
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
                    })
            }
        }
        
        
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(myData: QRData(), qrData: QRCode.sample[0])
        }
        
    }
}
