//
//  Extension.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import Foundation

// MARK: - Bool
extension Bool {
    
    /// Bool => Int
    var intValue: Int { self ? 1 : 0 }
}

// MARK: - JSONSerialization (subscript function)
extension Collection {
    
    /// 集合安全取值
    /// - Returns: Element?
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - JSONSerialization (static function)
extension JSONSerialization {
    
    /// [JSONObject => JSON Data](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-jsonserialization-印出美美縮排的-json-308c93b51643)
    /// - ["name":"William"] => {"name":"William"} => 7b226e616d65223a2257696c6c69616d227d
    /// - Parameters:
    ///   - object: Any
    ///   - options: JSONSerialization.WritingOptions
    /// - Returns: Data?
    static func data(with object: Any, options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: options)
        else {
            return nil
        }
        
        return data
    }
}

// MARK: - Data (function)
extension Data {
    
    /// Data => Class
    /// - Parameter type: 要轉型的Type => 符合Decodable
    /// - Returns: T => 泛型
    func `class`<T: Decodable>(type: T.Type) -> T? {
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "UTC")
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return try? decoder.decode(type.self, from: self)
    }
}

// MARK: - Dictionary (function)
extension Dictionary {
    
    /// Dictionary => JSON Data
    /// - ["name":"William"] => {"name":"William"} => 7b226e616d65223a2257696c6c69616d227d
    /// - Returns: Data?
    func jsonData(options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        return JSONSerialization.data(with: self, options: options)
    }
    
    /// Dictionary => JSON Data => T
    /// - Parameter type: 要轉換成的Dictionary類型
    /// - Returns: T?
    func jsonClass<T: Decodable>(for type: T.Type) -> T? {
        let dictionary = self.jsonData()?.`class`(type: type.self)
        return dictionary
    }
}
