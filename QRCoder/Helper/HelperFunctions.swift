//
//  Model.swift
//  QR Coder
//
//  Created by Simon Lang on 10.09.21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
//import WidgetKit


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

func codeFromString(name: String?, data: [QRCode]) -> QRCode? {
    
    return data.first(where: { (singleCode) -> Bool in
        return singleCode.id == name
    })
    
}

func stringFromQRData(codeData: QRCode.Datas) -> String {
    
    if codeData.qrCodeType == "Text" {
        return codeData.text
        
    } else if codeData.qrCodeType == "URL" {
        return codeData.url
        
    } else if codeData.qrCodeType == "Email" {
        return "mailto:\(codeData.email)"
        
    } else if codeData.qrCodeType == "Wi-Fi Access" {
        if codeData.encryptionType == "None" {
            return "WIFI:T:nopass;S:\(codeData.network);H:;;"
            
        } else if codeData.encryptionType == "WEP" {
            return "WIFI:T:WEP;S:\(codeData.network);P:\(codeData.password);H:\(codeData.hiddenNetwork);;"
            
        } else if codeData.encryptionType == "WPA/WPA2" {
            return "WIFI:T:WPA;S:\(codeData.network);P:\(codeData.password);H:\(codeData.hiddenNetwork);;"
        }
        
    } else if codeData.qrCodeType == "Contact" {
        if codeData.complexContact == false {
            return "MECARD:N:\(codeData.lastName),\(codeData.firstName);TEL:\(codeData.phoneNumber);EMAIL:\(codeData.email);;"
            
        } else if codeData.complexContact {
            if (codeData.address == "" && codeData.url == "http://") || (codeData.address == "" && codeData.url == "") {
                return
                    """
                    BEGIN:VCARD
                    VERSION:2.1
                    N:\(codeData.lastName);\(codeData.firstName);;;
                    TEL;HOME;VOICE:\(codeData.phoneNumber)
                    TEL;WORK;VOICE:\(codeData.workNumber)
                    EMAIL:\(codeData.email)
                    END:VCARD
                    """
                
            } else if codeData.address == "" {
                return
                    """
                    BEGIN:VCARD
                    VERSION:2.1
                    N:\(codeData.lastName);\(codeData.firstName);;;
                    TEL;HOME;VOICE:\(codeData.phoneNumber)
                    TEL;WORK;VOICE:\(codeData.workNumber)
                    EMAIL:\(codeData.email)
                    URL:\(codeData.url)
                    END:VCARD
                    """
                
            } else if codeData.url == "http://" || codeData.url == ""  {
                return
                    """
                    BEGIN:VCARD
                    VERSION:2.1
                    N:\(codeData.lastName);\(codeData.firstName);;;
                    TEL;HOME;VOICE:\(codeData.phoneNumber)
                    TEL;WORK;VOICE:\(codeData.workNumber)
                    ADR:\(codeData.address)
                    EMAIL:\(codeData.email)
                    END:VCARD
                    """
                
            } else {
                return
                    """
                BEGIN:VCARD
                VERSION:2.1
                N:\(codeData.lastName);\(codeData.firstName);;;
                TEL;HOME;VOICE:\(codeData.phoneNumber)
                TEL;WORK;VOICE:\(codeData.workNumber)
                ADR:\(codeData.address)
                EMAIL:\(codeData.email)
                URL:\(codeData.url)
                END:VCARD
                """
            }
        }
    }
    return "Didn't find anything to turn into a QR code."
    
}


