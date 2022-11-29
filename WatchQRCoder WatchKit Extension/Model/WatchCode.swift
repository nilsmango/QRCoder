//
//  QRCode.swift
//  QRCoder
//
//  Created by Simon Lang on 30.09.21.
//

import Foundation



struct WatchCode: Identifiable, Codable {
    var title: String
    var qrImage: Data?
    let id = UUID()
}


