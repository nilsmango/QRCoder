//
//  OptionView.swift
//  QRCoder
//
//  Created by Simon Lang on 30.11.22.
//

import SwiftUI

struct OptionView: View {
    
    var qrCodesCreated: Int
    
    var body: some View {
        List {
            
            Section(header: Text("Restore purchases")) {
                Button(action: {
                    //Restore products already purchased
                }) {
                    Text("Tap here")
                }
            }
            
            Section(header: Text("Why is my watch not showing any QR codes?")) {
                Text("Make sure the watch app is installed. Open both the watch app and the iPhone app to update the QR codes list on the watch.")
                Text("If you have both open and nothing happens you can try to pull down the QR code list to send the data again.")
                Text("Sometimes it just takes some time for the data to get transferred, if everything works the data will also get transferred in the background and updated the next time you open your watch app.")
            }
            
            
            
            Section(header: Text("Statistics")) {
                if qrCodesCreated == 69 {
                    Text("You have created 69 QR code. Nice! 👀")
                } else {
                    qrCodesCreated == 1 ? Text("You have created 1 QR code.") : Text("You have created \(qrCodesCreated) QR codes. Great job!")
                }
                
            }
            
            
            Section(header: Text("What about all my other questions?"), footer: Text("Changelog:\nVersion 1.0 - Made with ❤️ by [Nils Mango](https://nilsmango.ch), Switzerland and Tenerife, 2022.")) {
                
                Link(destination: URL(string: "mailto:0@project7iii.com")!, label: { Label("Feedback / Email", systemImage: "envelope") })
                

                Link(destination: URL(string: "https://project7iii.com")!, label: { Label("More from project7III", systemImage: "link") })
                
                Link(destination: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/")!, label: { Label("This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License, except where otherwise noted.", systemImage: "doc.on.doc") })
                
            }
            
        }
        
    }
}

struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView(qrCodesCreated: 12)
    }
}
