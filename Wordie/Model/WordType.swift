//
//  WordType.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/26.
//

import Foundation

// [英文八大詞性](https://blogs.bjes.tp.edu.tw/mika/英文學習/英文的所有詞性、英文、縮寫、用法/)
struct WordType: OptionSet {
    
    let rawValue: UInt8
    
    init(rawValue: UInt8) { self.rawValue = rawValue }
    
    static let noun         = WordType(rawValue: 1 << 0) // 0b0000_0001 (n.名詞)
    static let pronoun      = WordType(rawValue: 1 << 1) // 0b0000_0010 (pron.代名詞)
    static let verb         = WordType(rawValue: 1 << 2) // 0b0000_0100 (v.動詞)
    static let adjective    = WordType(rawValue: 1 << 3) // 0b0000_1000 (adj.形容詞)
    static let adverb       = WordType(rawValue: 1 << 4) // 0b0001_0000 (adv.副詞)
    static let preposition  = WordType(rawValue: 1 << 5) // 0b0010_0000 (prep.介系詞)
    static let conjunction  = WordType(rawValue: 1 << 6) // 0b0100_0000 (conj.連接詞)
    static let interjection = WordType(rawValue: 1 << 7) // 0b1000_0000 (interj.感嘆詞)
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
    
    /// 傳入任意 UInt8 數字，解碼並自動過濾掉未定義的無效位元
    ///
    /// 使用範例：
    /// let result = WordType.from(rawValue: 5) => 得到包含 [.verb, .adjective] 的 WordType
    static func from(rawValue: UInt8) -> Self {
        return Self(rawValue: rawValue).intersection(all)
    }
}

// MARK: - 公有屬性
extension WordType {
    
    /// 取得當前詞性的中文名稱（若為複合集合則以逗號分隔）
    var names: [String] {
        Self.mapping.filter { self.contains($0.0) }.map { $0.1 }
    }
}

// MARK: - 私有屬性
private extension WordType {
    
    /// 類型 <=> 名稱
    static let mapping: [(WordType, String)] = [
        (.noun, "名詞"),
        (.pronoun, "代名詞"),
        (.verb, "動詞"),
        (.adjective, "形容詞"),
        (.adverb, "副詞"),
        (.preposition, "介系詞"),
        (.conjunction, "接續詞"),
        (.interjection, "感嘆詞")
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
