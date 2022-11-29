//
//  PhoneConnection.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 28.11.22.
//

import Foundation
import WatchConnectivity
import SwiftUI


class PhoneConnection: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var codes: [WatchCode] = []
    
    let session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Message from Watch: The session has completed activation.")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if message.count == 1 {
                // only append the new QR code from iphone
                let title = message.keys.first
                let qrImage = message.values.first
                let newWatchCode = WatchCode(title: (title ?? "no title found") as String, qrImage: qrImage as? Data)
                self.codes.append(newWatchCode)
                print(title!)
                self.codes.sort {
                    $0.title < $1.title
                }
                
            } else {
                print("Mapping in progress")
                let titles = message.map {$0.key}
                let qrImages = message.map {$0.value}
                print(titles, qrImages)
                
                var newWatchCodes: [WatchCode] = []
                
                for index in 0..<titles.count {
                    let title = titles[index]
                    let qrImage = qrImages[index]
                    print(title, qrImage)
                    let newData = WatchCode(title: title, qrImage: qrImage as? Data)
                    newWatchCodes.append(newData)
                    
                }
                print(newWatchCodes)
                newWatchCodes.sort {
                    $0.title < $1.title
                }
                
                self.codes = newWatchCodes
                
            }
        }
    }
    
}
