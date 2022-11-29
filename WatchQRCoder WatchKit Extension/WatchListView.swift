//
//  WatchListView.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 05.11.21.
//

import SwiftUI



struct WatchListView: View {
    
    private var qrCodes: [WatchCode] = [WatchCode(title: "First Code"), WatchCode(title: "Another Code"), WatchCode(title: "This is a longer name but we don't care")]
    
    @ObservedObject var phoneConnection = PhoneConnection()
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(phoneConnection.codes) { code in
                        NavigationLink(destination: WatchDetailView(image: code.qrImage)) {
                            Text(code.title)
                        }
                    }
                }
                if phoneConnection.codes.isEmpty {
                    VStack {
                        Text("- Wow, such empty -")
                        Text("Open QRCoder on your iPhone and add QR Codes there to make them show up here.")
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("QRCoder")
            
            
        
        
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView()
    }
}
