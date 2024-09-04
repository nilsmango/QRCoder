//
//  OptionView.swift
//  QRCoder
//
//  Created by Simon Lang on 30.11.22.
//

import SwiftUI
import StoreKit

struct OptionView: View {
    @ObservedObject var myData: QRData
    
    var qrCodesCreated: Int
    
    var body: some View {
        List {
            
            Section(header: Text("Statistics")) {
                if qrCodesCreated == 69 {
                    Text("You have created 69 QR code. Nice! 👀")
                } else if qrCodesCreated == 0 {
                    Text("You have created no QR codes so far.")
                    
                } else {
                    qrCodesCreated == 1 ? Text("You have created 1 QR code. 😮") : Text("You have created \(qrCodesCreated) QR codes. Great job! 🎉")
                }
                
            }
            
            Section(header: Text("Why is my watch not showing any QR codes?")) {
                Text("""
                1. Ensure the watch app is installed.
                
                2. Open both the watch app and the iPhone app to update the QR codes list on the watch.
                
                3. If both apps are open and nothing happens, try pulling down the QR code list to resend the data.
                
                4. Sometimes, it may take a while for the data to transfer. If everything is working correctly, the data will be transferred in the background and updated the next time you open your watch app.
                """)
            }
            
            Section(header: Text("What about all my other questions?"), footer:
                        VStack {
                Text("Changelog:\nVersion 1.0 - Finished the app in Switzerland, 2024.\nVersion 0.1 - Made with ❤️ by [Nils Mango](https://nilsmango.ch) for project7III, Switzerland and Tenerife, 2022.\n\nThis work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License, except where otherwise noted.")
                
            }
                .padding(.top)
            ) {
                
                Link(destination: URL(string: "mailto:hi@project7iii.com")!) {
                    Label("Contact", systemImage: "envelope.fill")
                }
                
                Link(destination: URL(string: "https://project7iii.com")!, label: { Label("More from project7III", systemImage: "globe.europe.africa.fill") })
                
                
                
                Link(destination: URL(string: "https://project7iii.com/qr/privacy-policy/")!) {
                    Label("Privacy Policy", systemImage: "lock.fill")
                }
                
                Link(destination: URL(string: "https://project7iii.com/qr/terms-and-conditions/")!) {
                    Label("Terms and Conditions", systemImage: "doc.text.fill")
                }
                
                if myData.hasPurchasedPremium {
                    NavigationLink("Request a Refund") {
                        RefundView(myData: myData)
                    }
                } else {
                    Button {
                        Task {
                            try? await AppStore.sync()
                        }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise.circle.fill")
                    }
                }
            }
        }
    }
}

struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView(myData: QRData(), qrCodesCreated: 12)
    }
}
