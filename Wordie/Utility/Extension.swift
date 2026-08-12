//
//  Extension.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import Foundation
import SwiftUI

// MARK: - Bool
extension Bool {
    
    /// Bool => Int
    var intValue: Int { self ? 1 : 0 }
}

// MARK: - NSNumber (function)
extension NSNumber {
    
    /// [數字格式化 (123456.7890 => 123,456.789)](https://www.jianshu.com/p/81c3c100bda6)
    /// - Parameter format: [顯示的格式 - #,###.###](https://www.twblogs.net/a/5cb8c478bd9eee0eff45c9f1)
    /// - Returns: [String?](https://unicode.org/reports/tr35/tr35-6.html#Number_Format_Patterns)
    func positiveFormat(_ format: String = "#,###.###") -> String? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveFormat = format
        
        return formatter.string(from: self)
    }
}

// MARK: - String
extension String {
    
    /// 回傳去除前後空白與換行字元後的字串
    var removeWhitespacesAndNewlines: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Color
extension Color {
    
    static let githubDarkBlack = Color(hex: "#0D1117")  /// Github的暗黑模式底色
    static let darkRed = Color(hex: "#F30")             /// 暗紅色
    static let seaGreen = Color(hex: "#3C3")            /// 海洋色
    static let lightBlue = Color(hex: "#6CF")           /// 天藍色
    
    /// 16進制顏色轉換 => RGB (12-bit) / RRGGBB (24-bit) / AARRGGBB (32-bit)
    /// - Parameter hex: 16進制顏色色碼 (#0d1117)
    init(hex: String) {
        
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3: (a, r, g, b) = (255, ((int >> 8) & 0xF) * 0x11, ((int >> 4) & 0xF) * 0x11, (int & 0xF) * 0x11)
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
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
    func jsonData(options: JSONSerialization.WritingOptions = .init()) -> Data? {
        return JSONSerialization.data(with: self, options: options)
    }
    
    /// Dictionary => JSON Data => T
    /// - Parameter type: 要轉換成的Dictionary類型
    /// - Returns: T?
    func jsonClass<T: Decodable>(for type: T.Type) -> T? {
        let dictionary = jsonData()?.`class`(type: type.self)
        return dictionary
    }
}

// MARK: - View (function)
extension View {
    
    /// 一鍵收起所有鍵盤
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
