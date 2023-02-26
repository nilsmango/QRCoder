//
//  QRData.swift
//  QRCoder
//
//  Created by Simon Lang on 30.09.21.
//

import SwiftUI
import WidgetKit

class QRData: ObservableObject {
    
    private static var documentsFolder: URL {
//        do {
//            return try FileManager.default.url(for: .documentDirectory,
//                                                  in: .userDomainMask,
//                                                  appropriateFor: nil,
//                                                  create: false)
//
//            Oben alter weg, unten neue idee
            let appIdentifier = "group.qrcoder.codes"
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appIdentifier)!
            
//        } catch {
//            fatalError("Couldn't find documents directory")
//        }
    }
    
    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("qrcoder.data")
    }
    
    @Published var codes: [QRCode] = []
    
    func delete(at indexSet: IndexSet) {
        codes.remove(atOffsets: indexSet)
    }
    
    func move(from offset: IndexSet, to newPlace: Int) {
        codes.move(fromOffsets: offset, toOffset: newPlace)
    }
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                return
            }
            guard let qrCodes = try? JSONDecoder().decode([QRCode].self, from: data) else {
                fatalError("Couldn't decode saved codes data")
            }
            DispatchQueue.main.async {
                self?.codes = qrCodes
                
            }
        }
    }
 
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let codes = self?.codes else { fatalError("Self out of scope!") }
            guard let data = try? JSONEncoder().encode(codes) else { fatalError("Error encoding data") }
            
            do {
                let outFile = Self.fileURL
                try data.write(to: outFile)
                WidgetCenter.shared.reloadAllTimelines()
                
            } catch {
                fatalError("Couldn't write to file")
            }
        }
    }
}





