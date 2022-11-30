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
    
    func session(_ session: WCSession, didReceiveUserInfo message: [String : Any]) {
        
        DispatchQueue.main.async {
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
            
            self.save()
            
            
        }
    }
    
    
    
    // Load and save the local watch QR codes, works because of the extension. I honestly don't understand how.
    
    let saveKey = "WatchCodes"
    
    func load() {
        let defaults = UserDefaults.standard
        codes = try! defaults.decode([WatchCode].self, forKey: saveKey) ?? []
    }
    
    func save() {
        let defaults = UserDefaults.standard
        try? defaults.encode(codes, forKey: saveKey)

    }
}
