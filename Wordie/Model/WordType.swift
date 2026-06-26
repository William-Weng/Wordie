//
//  WordType.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/26.
//

import SwiftUI

// [英文八大詞性](https://blogs.bjes.tp.edu.tw/mika/英文學習/英文的所有詞性、英文、縮寫、用法/)
enum WordType: WordTypeDataSource {
    
    case noun           // 0b0000_0001 (n.名詞)
    case pronoun        // 0b0000_0010 (pron.代名詞)
    case verb           // 0b0000_0100 (v.動詞)
    case adjective      // 0b0000_1000 (adj.形容詞)
    case adverb         // 0b0001_0000 (adv.副詞)
    case preposition    // 0b0010_0000 (prep.介系詞)
    case conjunction    // 0b0100_0000 (conj.連接詞)
    case interjection   // 0b1000_0000 (interj.感嘆詞)
}

// MARK: - 公開屬性
extension WordType {
    
    /// 將詞性二進制值 => [WordType]
    /// - Parameter value: 二進制值
    /// - Returns: [WordType]
    static func parseTypes(from value: Int) -> [any WordTypeDataSource] {
        Self.allCases.filter { value & $0.binary != 0 }
    }
    
    /// 將詞性組二進位值組合
    /// - Parameter types: [WordType]
    /// - Returns: 組合完成的值
    static func combine(_ types: [WordType]) -> Int {
        types.reduce(0) { $0 | $1.binary }
    }
}

// MARK: - 公開屬性
extension WordType {
        
    // 中文名稱
    var name: String {
        
        switch self {
        case .noun: "名詞"
        case .pronoun: "代名詞"
        case .verb: "動詞"
        case .adjective: "形容詞"
        case .adverb: "副詞"
        case .preposition: "介系詞"
        case .conjunction: "連接詞"
        case .interjection: "感嘆詞"
        }
    }
    
    // 背景色
    var background: Color {
        
        switch self {
        case .noun: .blue
        case .pronoun: .green
        case .verb: .orange
        case .adjective: .pink
        case .adverb: .purple
        case .preposition: .teal
        case .conjunction: .indigo
        case .interjection: .red
        }
    }
    
    // 二進制數值
    var binary: Int {
        
        switch self {
        case .noun:         1 << 0
        case .pronoun:      1 << 1
        case .verb:         1 << 2
        case .adjective:    1 << 3
        case .adverb:       1 << 4
        case .preposition:  1 << 5
        case .conjunction:  1 << 6
        case .interjection: 1 << 7
        }
    }
    
    // 二進制數值文字
    var binaryString: String {
        String(binary, radix: 2)
    }
}
