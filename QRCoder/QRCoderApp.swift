//
//  QRCoderApp.swift
//  QRCoder
//
//  Created by Simon Lang on 30.09.21.
//

import SwiftUI



@main
struct QRCoderApp: App {
    
    @StateObject private var myData = QRData()
        
    var body: some Scene {
        WindowGroup {
            QRListView(myData: myData) {
                // this gets called in the ContentView saveAction closure.
                myData.save()

            }
            .onAppear() {
                myData.load()
                    
            }
        }
        
    }
}
