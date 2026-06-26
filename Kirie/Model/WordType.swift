//
//  WordType.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/26.
//

import Foundation

// [日文十大品詞](https://www.sigure.tw/learn-japanese/grammar/n5/00)
struct WordType: OptionSet {
    
    // 提升至 UInt16 以容納十大品詞（共需 10 個獨立位元）
    let rawValue: UInt16
    
    init(rawValue: UInt16) { self.rawValue = rawValue }

    // === 自立語・有活用（用言） ===
    static let verb          = WordType(rawValue: 1 << 0)  // 0b0000_0000_0000_0001 (動詞)
    static let iAdjective    = WordType(rawValue: 1 << 1)  // 0b0000_0000_0000_0010 (い形容詞)
    static let naAdjective   = WordType(rawValue: 1 << 2)  // 0b0000_0000_0000_0100 (な形容詞)

    // === 自立語・無活用（體言） ===
    static let noun          = WordType(rawValue: 1 << 3)  // 0b0000_0000_0000_1000 (名詞/代名詞)

    // === 自立語・無活用（修飾/獨立） ===
    static let adverb        = WordType(rawValue: 1 << 4)  // 0b0000_0000_0001_0000 (副詞)
    static let preNounAdverb = WordType(rawValue: 1 << 5)  // 0b0000_0000_0010_0000 (連體詞)
    static let conjunction   = WordType(rawValue: 1 << 6)  // 0b0000_0000_0100_0000 (接續詞)
    static let interjection  = WordType(rawValue: 1 << 7)  // 0b0000_0000_1000_0000 (感動詞)

    // === 附屬語 ===
    static let auxiliaryVerb = WordType(rawValue: 1 << 8)  // 0b0000_0001_0000_0000 (助動詞)
    static let particle      = WordType(rawValue: 1 << 9)  // 0b0000_0010_0000_0000 (助詞)
    
    // === 便利組合（Convenience Sets） ===
    static let yogen: WordType = [.verb, .iAdjective, .naAdjective]
    static let taigen: WordType = [.noun]
}

// MARK: - Codable
extension WordType: Codable {}
extension WordType {
    
    init(from decoder: Decoder) throws {
        self = try Self.decodeType(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        try encodeType(to: encoder)
    }
}

// MARK: - 公有屬性
extension WordType {
    
    /// 取得全屬性
    static let all: Self = { Self.mapping.reduce(Self()) { $0.union($1.0) }}()
}

// MARK: - 公有API
extension WordType {
    
    /// 傳入任意 UInt16 數字，解碼並自動過濾掉未定義的無效位元
    ///
    /// 使用範例：
    /// let result = WordType.from(rawValue: 5) => 得到包含 [.verb, .naAdjective] 的 WordType
    static func from(rawValue: UInt16) -> Self {
        return Self(rawValue: rawValue).intersection(all)
    }
}

// MARK: - 公有屬性
extension WordType {
    
    /// 取得當前品詞的中文名稱（若為複合集合則以逗號分隔）
    var names: [String] {
        Self.mapping.filter { self.contains($0.0) }.map { $0.1 }
    }
}

// MARK: - 私有屬性
private extension WordType {

    /// 類型 <=> 名稱
    static let mapping: [(WordType, String)] = [
        
        // === 自立語・有活用（用言） ===
        (.verb, "動詞"),
        (.iAdjective, "い形容詞"),
        (.naAdjective, "な形容詞"),
        
        // === 自立語・無活用（體言） ===
        (.noun, "名詞"),
        
        // === 自立語・無活用（修飾/獨立） ===
        (.adverb, "副詞"),
        (.preNounAdverb, "連體詞"),
        (.conjunction, "接續詞"),
        (.interjection, "感動詞"),
        
        // === 附屬語 ===
        (.auxiliaryVerb, "助動詞"),
        (.particle, "助詞")
    ]
}

// MARK: - 私有API
private extension WordType {
    
    /// 從 Decoder 解出 WordType => 預期輸入格式為字串陣列，例如：["noun", "verb"]
    static func decodeType(from decoder: Decoder) throws -> WordType {
        
        var container = try decoder.unkeyedContainer()  // 取得未命名容器，對應 JSON array
        var result: WordType = []
        
        while !container.isAtEnd {
            let name = try container.decode(String.self)
            if let pair = mapping.first(where: { $0.1 == name }) { result.insert(pair.0) }
        }
        
        return result
    }
}

// MARK: - 私用API
private extension WordType {
        
    /// 將 WordType 編碼成 Encoder => 輸出格式為字串陣列，例如：["noun", "verb"]
    func encodeType(to encoder: Encoder) throws {
        
        var container = encoder.unkeyedContainer()
        
        for (flag, name) in Self.mapping {
            if self.contains(flag) { try container.encode(name) }
        }
    }
}
