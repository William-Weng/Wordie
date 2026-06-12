//
//  Word.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import Foundation
import WWSQLite3Manager

/// 單字模型 => 用來儲存一個單字的英文、音標與中文翻譯
struct Word: Codable, Identifiable {
    
    let id: Int             // 流水號
    let english: String     // 英文單字
    let phonetic: String    // 音標
    let chinese: String     // 中文翻譯
}

// MARK: - WWSQLite3Manager.SchemeDelegate
extension Word: WWSQLite3Manager.SchemeDelegate {
    
    /// 用來初始化SQL的表結構
    /// - Returns: WWSQLite3Manager.SchemeColumn
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        [
            (key: "id", type: .INTEGER()),
            (key: "english", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "phonetic", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "chinese", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "time", type: .TIMESTAMP()),
        ]
    }
}
