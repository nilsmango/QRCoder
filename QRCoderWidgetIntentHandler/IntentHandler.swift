//
//  IntentHandler.swift
//  QRCoderWidgetIntentHandler
//
//  Created by Simon Lang on 28.10.21.
//

import Intents
import SwiftUI

class IntentHandler: INExtension, ConfigurationIntentHandling {
    private static var documentsFolder: URL {
            let appIdentifier = "group.qrcode"
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appIdentifier)!
    }
    
    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("qrcoder.data")
    }
    
    private func load() -> [QRCode] {
        
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                print("Couldn't load data in intent handler")
                return []
            }
            guard let qrCodes = try? JSONDecoder().decode([QRCode].self, from: data) else {
                fatalError("Couldn't decode saved codes data")
            }
            
            print(qrCodes, "Intenthandler load func")
                
            return qrCodes
        }
    
    
    func provideChooseQRCodeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<SelectedCode>?, Error?) -> Void) {
        
        let codes = load()
        
        let coders: [SelectedCode] = codes.map { coder in
            let code = SelectedCode(identifier: coder.id, display: coder.title)
            
            print(codes, "IntentHandler")
            
            return code
        }
        
        let collection = INObjectCollection(items: coders)
        
        completion(collection, nil)
    }
    
    

 
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
