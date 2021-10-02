//
//  ShareSheet.swift
//  QRCoder
//
//  Created by Simon Lang on 02.10.21.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIActivityViewController
  
}
