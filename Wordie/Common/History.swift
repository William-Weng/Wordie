//
//  History.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/22.
//

import Foundation
import WWSQLite3Manager

/// 單字歷史 => 用來記憶已背過的單字
struct History: Codable {
    
    static let tableName: String = "History"
    
    let id: Int             // 流水號
    let word: String        // 單字
    let difficulty: Int     // 難度 (越大越難)
    let time: Date          // 單字新增時間
}

// MARK: - WWSQLite3Manager.SchemeDelegate
extension History: WWSQLite3Manager.SchemeDelegate {
    
    /// 用來初始化SQL的表結構
    /// - Returns: WWSQLite3Manager.SchemeColumn
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        [
            (key: "id", type: .INTEGER()),
            (key: "word", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "difficulty", type: .INTEGER(attribute: (isNotNull: true, isNoCase: true, isUnique: false), defaultValue: 0)),
            (key: "time", type: .TIMESTAMP()),
        ]
    }
}
