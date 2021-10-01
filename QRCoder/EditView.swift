//
//  EditView.swift
//  QRCoder
//
//  Created by Simon Lang on 01.10.21.
//

import SwiftUI

struct EditView: View {
    @Binding var codeData: QRCode.Data
    
    var body: some View {
        VStack {
            QRCodeView(qrString: codeData.title)
                .padding(10)
            List {
                Section() {
                    TextField("Your Title...", text: $codeData.title)
                }
                
            }
            
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(codeData: .constant(QRCode.sample[0].data))
    }
}
