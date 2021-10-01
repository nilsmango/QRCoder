//
//  Model.swift
//  QR Coder
//
//  Created by Simon Lang on 10.09.21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins


func generateQRCode(from string: String) -> UIImage {
    let data = Data(string.utf8)
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    filter.setValue(data, forKey: "inputMessage")
    
    if let outputImage = filter.outputImage {
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    return UIImage(systemName: "xmark.circle") ?? UIImage()
}


