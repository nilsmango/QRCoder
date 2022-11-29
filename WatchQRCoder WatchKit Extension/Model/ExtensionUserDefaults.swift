//
//  ExtensionUserDefaults.swift
//  WatchQRCoder WatchKit Extension
//
//  Created by Simon Lang on 29.11.22.
//

import Foundation


//extension UserDefaults {
//    func setEncodable<T: Encodable>(_ encodable: T, for key: String) throws {
//        let data = try PropertyListEncoder().encode(encodable)
//        self.set(data, forKey: key)
//    }
//
//    func getDecodable<T: Decodable>(for key: String) -> T? {
//        guard
//            self.object(forKey: key) != nil,
//            let data = self.value(forKey: key) as? Data
//        else {
//            return nil
//        }
//
//        let obj = try? PropertyListDecoder().decode(T.self, from: data)
//        return obj
//    }
//}


extension UserDefaults {
    func encode<T: Encodable>(_ value: T?, forKey key: String) throws {
        let data = try value.map(PropertyListEncoder().encode)
        let any = data.map { try! PropertyListSerialization.propertyList(from: $0, options: [], format: nil) }
        
        set(any, forKey: key)
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        let any = object(forKey: key)
        let data = any.map { try! PropertyListSerialization.data(fromPropertyList: $0, format: .binary, options: 0) }
        
        return try data.map { try PropertyListDecoder().decode(type, from: $0) }
    }
}
