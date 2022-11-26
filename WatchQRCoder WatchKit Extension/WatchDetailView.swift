//
//  WatchDetailView.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 05.11.21.
//

import SwiftUI

struct WatchDetailView: View {
    let code: WatchCode
    var body: some View {
        VStack {
//            qrCodeImage here omg
        }
        .navigationTitle(code.title)
    }
}

struct WatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WatchDetailView(code: WatchCode(title: "Name of QR", qrString: "Something"))
    }
}
