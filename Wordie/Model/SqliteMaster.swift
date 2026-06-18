//
//  SqliteMaster.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/18.
//

import Foundation
import WWSQLite3Manager

/// 單字模型 => 用來儲存一個單字的英文、音標與中文翻譯
struct SqliteMaster: Codable {
    
    let type: String
    let name: String
    let tbl_name: String
    let rootpage: Int
    let sql: String
}

// MARK: - WWSQLite3Manager.SchemeDelegate
extension SqliteMaster: WWSQLite3Manager.SchemeDelegate {
    
    /// 用來初始化SQL的表結構
    /// - Returns: WWSQLite3Manager.SchemeColumn
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        [
            (key: "type", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "name", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "tbl_name", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
            (key: "rootpage", type: .INTEGER(attribute: (isNotNull: true, isNoCase: true, isUnique: false), defaultValue: 0)),
            (key: "sql", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true), defaultValue: nil)),
        ]
    }
}
