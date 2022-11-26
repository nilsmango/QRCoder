//
//  QRCoderApp.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 05.11.21.
//

import SwiftUI

@main
struct QRCoderApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WatchListView()
            }
        }
    }
}
