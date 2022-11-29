//
//  WatchDetailView.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 05.11.21.
//

import SwiftUI

struct WatchDetailView: View {
    let image: Data?
    var body: some View {
        
        Image(uiImage: UIImage(data: image!)!)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
       // .navigationTitle(code.title)
    }
}

struct WatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WatchDetailView(image: nil)
    }
}
