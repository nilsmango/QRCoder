//
//  QRCode.swift
//  QRCoder
//
//  Created by Simon Lang on 30.09.21.
//

import Foundation

struct QRCode: Identifiable, Codable {
    var title: String
    var qrCodeType: String
    var complexContact: Bool
    var hiddenNetwork: Bool
    var text: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var workNumber: String
    var address: String
    var url: String
    var network: String
    var password: String
    var encryptionType: String
    
    var qrString: String {
        if qrCodeType == "Text" {
            return text
        } else if qrCodeType == "URL" {
            return url
            
        } else if qrCodeType == "Email" {
            return "mailto:\(email)"
            
        } else if qrCodeType == "Wi-Fi Access" {
            if encryptionType == "None" {
                return "WIFI:T:nopass;S:\(network);H:;;"
                
            } else if encryptionType == "WEP" {
                return "WIFI:T:WEP;S:\(network);P:\(password);H:\(hiddenNetwork);;"
                
            } else if encryptionType == "WPA/WPA2" {
                return "WIFI:T:WPA;S:\(network);P:\(password);H:\(hiddenNetwork);;"
            }
            
        } else if qrCodeType == "Contact" {
            if complexContact == false {
                return "MECARD:N:\(lastName),\(firstName);TEL:\(phoneNumber);EMAIL:\(email);;"
                
            } else if complexContact {
                if (address == "" && url == "http://") || (address == "" && url == "") {
                    return
                        """
                        BEGIN:VCARD
                        VERSION:2.1
                        N:\(lastName);\(firstName);;;
                        TEL;HOME;VOICE:\(phoneNumber)
                        TEL;WORK;VOICE:\(workNumber)
                        EMAIL:\(email)
                        END:VCARD
                        """
                    
                } else if address == "" {
                    return
                        """
                        BEGIN:VCARD
                        VERSION:2.1
                        N:\(lastName);\(firstName);;;
                        TEL;HOME;VOICE:\(phoneNumber)
                        TEL;WORK;VOICE:\(workNumber)
                        EMAIL:\(email)
                        URL:\(url)
                        END:VCARD
                        """
                    
                } else if url == "http://" || url == ""  {
                    return
                        """
                        BEGIN:VCARD
                        VERSION:2.1
                        N:\(lastName);\(firstName);;;
                        TEL;HOME;VOICE:\(phoneNumber)
                        TEL;WORK;VOICE:\(workNumber)
                        ADR:\(address)
                        EMAIL:\(email)
                        END:VCARD
                        """
                    
                } else {
                    return
                        """
                    BEGIN:VCARD
                    VERSION:2.1
                    N:\(lastName);\(firstName);;;
                    TEL;HOME;VOICE:\(phoneNumber)
                    TEL;WORK;VOICE:\(workNumber)
                    ADR:\(address)
                    EMAIL:\(email)
                    URL:\(url)
                    END:VCARD
                    """
                }
            }
        }
        return "Didn't find anything to turn into a QR code."
        
    }

    let id: String
    
    init(title: String, qrCodeType: String, complexContact: Bool, hiddenNetwork: Bool, text: String ,firstName: String, lastName: String, email: String, phoneNumber: String, workNumber: String, address: String, url: String, network: String, password: String, encryptionType: String, id: String = UUID().uuidString) {
        
        self.title = title
        self.qrCodeType = qrCodeType
        self.complexContact = complexContact
        self.hiddenNetwork = hiddenNetwork
        self.text = text
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.workNumber = workNumber
        self.address = address
        self.url = url
        self.network = network
        self.password = password
        self.encryptionType = encryptionType
        self.id = id
    }

}

extension QRCode {
    static var sampleData: [QRCode] {
        [
            QRCode(title: "Your QR Code", qrCodeType: "Text", complexContact: false, hiddenNetwork: false, text: "This is your QR Code", firstName: "", lastName: "", email: "", phoneNumber: "", workNumber: "", address: "", url: "", network: "", password: "", encryptionType: "None"),
            QRCode(title: "My Simple Contact", qrCodeType: "Contact", complexContact: false, hiddenNetwork: false, text: "", firstName: "Maxi", lastName: "Mustermann", email: "max@muster.com", phoneNumber: "07777777", workNumber: "", address: "", url: "", network: "", password: "", encryptionType: "None"),
            QRCode(title: "My Complex Contact", qrCodeType: "Contact", complexContact: true, hiddenNetwork: false, text: "", firstName: "Miri", lastName: "Muster", email: "miri@muster.ch", phoneNumber: "0238283291", workNumber: "0382822991", address: "Im Musterwald 12, 4058 Basel", url: "http://musterfrau.ch", network: "", password: "", encryptionType: "None"),
            QRCode(title: "My Email", qrCodeType: "Email", complexContact: false, hiddenNetwork: false, text: "", firstName: "", lastName: "", email: "meine@email.com", phoneNumber: "", workNumber: "", address: "", url: "", network: "", password: "", encryptionType: "None")
        ]
    }
}

extension QRCode {
    struct Data {
        var title: String = ""
        var qrCodeType: String = "Text"
        var complexContact: Bool = false
        var hiddenNetwork: Bool = false
        var text: String = ""
        var firstName: String = ""
        var lastName: String = ""
        var email: String = ""
        var phoneNumber: String = ""
        var workNumber: String = ""
        var address: String = ""
        var url: String = ""
        var network: String = ""
        var password: String = ""
        var encryptionType: String = "WPA/WPA2"
    }
    
    var data: Data {
        return Data(title: title, qrCodeType: qrCodeType, complexContact: complexContact, hiddenNetwork: hiddenNetwork, text: text, firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, workNumber: workNumber, address: address, url: url, network: network, password: password, encryptionType: encryptionType)
    }
    
    mutating func update(from data: Data) {
        title = data.title
        qrCodeType = data.qrCodeType
        complexContact = data.complexContact
        hiddenNetwork = data.hiddenNetwork
        text = data.text
        firstName = data.firstName
        lastName = data.lastName
        email = data.email
        phoneNumber = data.phoneNumber
        workNumber = data.workNumber
        address = data.address
        url = data.url
        network = data.network
        password = data.password
        encryptionType = data.encryptionType
    }
}
