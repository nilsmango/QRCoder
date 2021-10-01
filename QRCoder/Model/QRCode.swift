//
//  QRCode.swift
//  QRCoder
//
//  Created by Simon Lang on 30.09.21.
//

import Foundation

struct QRCode: Identifiable, Codable {
    var title: String
    let id: UUID
    
    init(title: String, id: UUID = UUID()) {
        self.title = title
        self.id = id
    }
}

extension QRCode {
    static var sample: [QRCode] {
        [
        QRCode(title: "Text 0"),
        QRCode(title: "Text 1"),
        QRCode(title: "Text 2"),
        QRCode(title: "Text 3"),
        QRCode(title: "Text 4")
        ]
    }
}

extension QRCode {
    struct Data {
        var title: String = ""
    }
    
    var data: Data {
        return Data(title: title)
    }
    
    mutating func update(from data: Data) {
        title = data.title
    }
}
