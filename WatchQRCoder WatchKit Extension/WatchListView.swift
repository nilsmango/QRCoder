//
//  WatchListView.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 05.11.21.
//

import SwiftUI

struct WatchCode: Identifiable {
    var title: String
    var qrString: String
    let id = UUID()
}

struct WatchListView: View {
    private var qrCodes = [WatchCode(title: "First Code", qrString: "First Code"), WatchCode(title: "Another Code", qrString: "Second Code"), WatchCode(title: "This is a longer name", qrString: "Really long stupid qr code")]
    
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(qrCodes) { code in
                        NavigationLink(destination: WatchDetailView(code: code)) {
                                Text(code.title)
                        }
                    }
//                    .onDelete { indexSet in
//                        qrCodes.delete(at: indexSet)
//                    }
//                    .onMove { indexSet, newPlace in
//                        qrCodes.move(from: indexSet, to: newPlace)
//                    }
                    
                }
                if qrCodes.isEmpty {
                    VStack {
                        Text("- Wow, such empty -")
                        Text("Go to your iPhone and add QR Codes there")
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
