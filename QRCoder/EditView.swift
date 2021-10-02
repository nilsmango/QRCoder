//
//  EditView.swift
//  QRCoder
//
//  Created by Simon Lang on 01.10.21.
//

import SwiftUI

struct EditView: View {
    @Binding var codeData: QRCode.Data
    
    enum QRCodeType: String, CaseIterable, Identifiable {
        case contact = "Contact"
        case wifiAccess = "Wi-Fi Access"
        case url = "URL"
        case text = "Text"
        case email = "Email"
        //        case event = "Event"
        //        case location = "Location"
        
        var id: String { self.rawValue }
    }
    
    enum EncryptionType: String, CaseIterable, Identifiable {
        case none = "None"
        case wep = "WEP"
        case wpa = "WPA/WPA2"
        
        var id: String { self.rawValue }
    }
    
    private var stringGenerator: String {
        
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
    
    var body: some View {
        VStack {
            Image(uiImage: generateQRCode(from: stringGenerator))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding()
            List {
                Section() {
                    Picker("QR Code Type", selection: $codeData.qrCodeType) {
                        ForEach(QRCodeType.allCases) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                }
                Section(header: Text("QR Code Name")) {
                    TextField("Name", text: $codeData.title)
                        .disableAutocorrection(true)
                }
                Group {
                    if codeData.qrCodeType == "Text" {
                        Section(header: Text("\(codeData.qrCodeType)")) {
                            TextField("Your text...", text: $codeData.text)
                                .disableAutocorrection(true)
                        }
                    } else if codeData.qrCodeType == "URL" {
                        Section(header: Text("\(codeData.qrCodeType)")) {
                            TextField("Your URL...", text: $codeData.url)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        }
                    } else if codeData.qrCodeType == "Email" {
                        Section(header: Text("\(codeData.qrCodeType)")) {
                            TextField("nils@7III.ch", text: $codeData.email)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        }
                    } else if codeData.qrCodeType == "Wi-Fi Access" {
                        Section(header: Text("\(codeData.qrCodeType)")) {
                            TextField("Network name", text: $codeData.network)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            Picker("Encryption", selection: $codeData.encryptionType) {
                                ForEach(EncryptionType.allCases) { encryption in
                                    Text(encryption.rawValue).tag(encryption)
                                }
                            }
                            
                            if codeData.encryptionType != "None" {
                                TextField("Password", text: $codeData.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                Toggle("Hidden network", isOn: $codeData.hiddenNetwork)
                            }
                        }
                    } else if codeData.qrCodeType == "Contact" {
                        Section(header: Text("\(codeData.qrCodeType)"), footer: Text("There is no need to fill in all the text fields. You can enter the data you want to share only.")) {
                            Toggle("Extended contact Info", isOn: $codeData.complexContact)
                            TextField("First Name", text: $codeData.firstName)
                                .disableAutocorrection(true)
                            TextField("Last Name", text: $codeData.lastName)
                                .disableAutocorrection(true)
                            TextField("Phone Number", text: $codeData.phoneNumber)
                            
                            if codeData.complexContact {
                                TextField("Work Phone Number", text: $codeData.workNumber)
                            }
                            TextField("Email", text: $codeData.email)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            if codeData.complexContact {
                                TextField("Address", text: $codeData.address)
                                    .disableAutocorrection(true)
                                
                                TextField("URL", text: $codeData.url)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                        }
                    } else {
                        
                    }
                    
                }
            }
            .listStyle(InsetGroupedListStyle())
            
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(codeData: .constant(QRCode.sampleData[0].data))
    }
}
