//
//  Word.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/16.
//

import Foundation
import WWSQLite3Manager

/// 單字模型 => 用來儲存一個單字的日文、假名與中文翻譯
struct Word: Codable, Identifiable {
    
    let id: Int             // 流水號
    let japanese: String    // 日文單字
    let kana: String        // 假名
    let category: Int       // 單字詞性 (對應 WordType)
    let chinese: String     // 中文翻譯
    let level: Int          // 單字等級分類 (越大等級越高)
    let time: Date          // 單字新增時間
}

// MARK: - WWSQLite3Manager.SchemeDelegate
extension Word: WWSQLite3Manager.SchemeDelegate {
    
    /// 用來初始化SQL的表結構
    /// - Returns: WWSQLite3Manager.SchemeColumn
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        [
            (key: "id", type: .INTEGER()),
            (key: "japanese", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "kana", type: .TEXT(attribute: (isNotNull: false, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "category", type: .INTEGER(attribute: (isNotNull: true, isNoCase: true, isUnique: false), defaultValue: 0)),
            (key: "chinese", type: .TEXT(attribute: (isNotNull: false, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "level", type: .INTEGER(attribute: (isNotNull: true, isNoCase: true, isUnique: false), defaultValue: 0)),
            (key: "time", type: .TIMESTAMP()),
        ]
    }
}

// MARK: - WordCardDataSource
extension Word: WordCardDataSource {
    
    /// 轉成共用型WordCard
    func toWordCard() -> WordCard {
        let level = WordLevel(rawValue: level) ?? .N5
        return WordCard(id: id, word: japanese, reading: kana, category: category, chinese: chinese, level: level)
    }
}
