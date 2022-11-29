//
//  WatchConnection.swift
//  QRCoder
//
//  Created by Simon Lang on 28.11.22.
//

import Foundation
import WatchConnectivity


class WatchConnection: NSObject, WCSessionDelegate {
    
    
  //  if WCSession.isSupported() {
    //    let session = WCSession.defaultSession()
    //    session.delegate = self
   //     session.activateSession()
  //  }
    
        
    let session: WCSession

        init(session: WCSession  = .default) {
            self.session = session
            super.init()
            self.session.delegate = self
            session.activate()
        }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Message from iPhone: The session has completed activation.")
            }
        }
    

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }
    
    
}
