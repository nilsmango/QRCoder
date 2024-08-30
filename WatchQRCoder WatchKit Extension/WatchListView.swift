//
//  WatchListView.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 05.11.21.
//

import SwiftUI



struct WatchListView: View {
    
    @ObservedObject var phoneConnection = PhoneConnection()
    @State private var appearedOnce = false
    
    var body: some View {
            Group {
                if phoneConnection.codes.isEmpty {
                    VStack {
                        Text("- Wow, such empty -")
                        Text("Open QRCoder on your iPhone and add QR Codes there to make them show up here.")
                    }
                    .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(phoneConnection.codes) { code in
                            NavigationLink(destination: WatchDetailView(image: code.qrImage)) {
                                Text(code.title)
                                    .accessibilityLabel("QR code title")
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear() {
                if appearedOnce == false {
                    phoneConnection.load()
                    appearedOnce = true
                }
            }
            .navigationTitle("QR Coder")
        }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView()
    }
}
