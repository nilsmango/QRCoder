//
//  QRCodeView.swift
//  QRCoder
//
//  Created by Simon Lang on 01.10.21.
//

import SwiftUI

struct QRCodeView: View {
    
    var qrString: String
    
    var body: some View {
            Image(uiImage: generateQRCode(from: qrString))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
    }
}

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(qrString: "Some Text")
    }
}
