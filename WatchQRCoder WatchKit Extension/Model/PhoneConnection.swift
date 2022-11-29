//
//  PhoneConnection.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 28.11.22.
//

import Foundation
import WatchConnectivity


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
                // find if new code is duplicate title, and change it
                let newWatchCode: WatchCode
                if (self.codes.filter{ $0.title == title }).count > 0 {
                    let count = String((self.codes.filter{ $0.title == title }).count + 1)
                    let newTitle = title! + " " + count
                    if (self.codes.filter{ $0.title == newTitle }).count > 0 {
                        let count2 = String((self.codes.filter{ $0.title == newTitle }).count + 2)
                        // TODO: count anfügen, und bei newTitle, der letzte Buchstaben entfernen.
                        let newestTitle = newTitle.dropLast() + count2
                        newWatchCode = WatchCode(title: String(newestTitle), qrImage: qrImage as? Data)
                    } else {
                        newWatchCode = WatchCode(title: newTitle as String, qrImage: qrImage as? Data)
                    }
                    
                } else {
                    newWatchCode = WatchCode(title: (title ?? "no title found") as String, qrImage: qrImage as? Data)
                }
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
