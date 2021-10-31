//
//  IntentHandler.swift
//  QRCoderWidgetIntentHandler
//
//  Created by Simon Lang on 28.10.21.
//

import Intents
import SwiftUI

class IntentHandler: INExtension, ConfigurationIntentHandling {
    
    
    func provideChooseQRCodeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<SelectedCode>?, Error?) -> Void) {
        
        
        let coders: [SelectedCode] = QRData().codes.map { coder in
            let code = SelectedCode(identifier: coder.qrString, display: coder.title)
            
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
