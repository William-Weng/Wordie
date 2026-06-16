//
//  JapaneseWord.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/16.
//

import Foundation
import WWSQLite3Manager

struct JapaneseWord: Codable, Identifiable {
    
    let id: Int             // 流水號
    let japanese: String    // 日文單字
    let phonetic: String    // 音標
    let chinese: String     // 中文翻譯
}

// MARK: - WWSQLite3Manager.SchemeDelegate
extension JapaneseWord: WWSQLite3Manager.SchemeDelegate {
    
    /// 用來初始化SQL的表結構
    /// - Returns: WWSQLite3Manager.SchemeColumn
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        [
            (key: "id", type: .INTEGER()),
            (key: "japanese", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "phonetic", type: .TEXT(attribute: (isNotNull: false, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "chinese", type: .TEXT(attribute: (isNotNull: false, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "example", type: .TEXT(attribute: (isNotNull: false, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "translation", type: .TEXT(attribute: (isNotNull: false, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "time", type: .TIMESTAMP()),
        ]
    }
}

// MARK: - WordCardDataSource
extension JapaneseWord: WordCardDataSource {
    
    func toWordCard() -> WordCard {
        WordCard(id: id, word: japanese, reading: phonetic, chinese: chinese)
    }
}
