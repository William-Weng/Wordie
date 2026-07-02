//
//  WordCategory.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/26.
//

import SwiftUI

// [日文十大品詞](https://www.sigure.tw/learn-japanese/grammar/n5/00)
enum WordCategory: WordCategoryDataSource {
    
    // === 自立語・有活用（用言） ===
    case verb           // 0b0000_0000_0000_0001 (動詞)
    case iAdjective     // 0b0000_0000_0000_0010 (い形容詞)
    case naAdjective    // 0b0000_0000_0000_0100 (な形容詞)
    
    // === 自立語・無活用（體言） ===
    case noun           // 0b0000_0000_0000_1000 (名詞/代名詞)
    
    // === 自立語・無活用（修飾/獨立） ===
    case adverb         // 0b0000_0000_0001_0000 (副詞)
    case preNounAdverb  // 0b0000_0000_0010_0000 (連體詞)
    case conjunction    // 0b0000_0000_0100_0000 (接續詞)
    case interjection   // 0b0000_0000_1000_0000 (感動詞)
    
    // === 附屬語 ===
    case auxiliaryVerb  // 0b0000_0001_0000_0000 (助動詞)
    case particle       // 0b0000_0010_0000_0000 (助詞)}
}

// MARK: - 公開API
extension WordCategory {
    
    /// 將詞性二進制值 => [WordType]
    /// - Parameter value: 二進制值
    /// - Returns: [WordCategoryDataSource]
    static func parseTypes(from value: Int) -> [Self] {
        Self.allCases.filter { value & $0.binary != 0 }
    }
    
    /// 快速轉成 ["名稱": "顏色"]
    /// - Returns: [String: Color]
    static func dictionary() -> [String: Color] {
        Dictionary(uniqueKeysWithValues: Self.allCases.map { ($0.name, $0.background) })
    }
    
    /// 將詞性組二進位值組合
    /// - Parameter types: [WordType]
    /// - Returns: 組合完成的值
    static func combine(_ types: [WordCategory]) -> Int {
        types.reduce(0) { $0 | $1.binary }
    }
}

// MARK: - 公開屬性
extension WordCategory {
    
    // Identifiable
    var id: Int { binary }
    
    // 中文名稱
    var name: String {
        
        switch self {
        case .verb:          "動詞"
        case .iAdjective:    "い形"
        case .naAdjective:   "な形"
        case .noun:          "名詞"
        case .adverb:        "副詞"
        case .preNounAdverb: "連體詞"
        case .conjunction:   "接続詞"
        case .interjection:  "感動詞"
        case .auxiliaryVerb: "助動詞"
        case .particle:      "助詞"
        }
    }

    // 背景色
    var background: Color {
        
        switch self {
        case .verb:          .orange
        case .iAdjective:    .green
        case .naAdjective:   .teal
        case .noun:          .blue
        case .adverb:        .purple
        case .preNounAdverb: .mint
        case .conjunction:   .indigo
        case .interjection:  .red
        case .auxiliaryVerb: .pink
        case .particle:      .gray
        }
    }
    
    // 二進制數值
    var binary: Int {
        
        switch self {
        case .verb:          1 << 0
        case .iAdjective:    1 << 1
        case .naAdjective:   1 << 2
        case .noun:          1 << 3
        case .adverb:        1 << 4
        case .preNounAdverb: 1 << 5
        case .conjunction:   1 << 6
        case .interjection:  1 << 7
        case .auxiliaryVerb: 1 << 8
        case .particle:      1 << 9
        }
    }
    
    // 二進制數值文字
    var binaryString: String {
        String(binary, radix: 2)
    }
}
