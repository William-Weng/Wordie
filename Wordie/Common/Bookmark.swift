//
//  Bookmark.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import Foundation
import WWSQLite3Manager

/// 書籤記錄 (記錄一些外語教學網頁)
struct Bookmark: Codable, Identifiable, Hashable {
    
    // 資料表名稱
    static let tableName: String = "Bookmark"
    
    let id: Int         // 流水號
    let title: String   // 網頁名稱
    let url: String     // 網頁地址
    let icon: String    // 網頁圖示
    let time: Date      // 更新時間
    
    var favorite: Int   // 是否常用 (0: FALSE / 1: TRUE)
}

// MARK: - WWSQLite3Manager.SchemeDelegate
extension Bookmark: WWSQLite3Manager.SchemeDelegate {
    
    /// 用來初始化SQL的表結構
    /// - Returns: WWSQLite3Manager.SchemeColumn
    static func structure() -> [WWSQLite3Manager.SchemeColumn] {
        [
            (key: "id", type: .INTEGER()),
            (key: "title", type: .TEXT(attribute: (isNotNull: false, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "url", type: .TEXT(attribute: (isNotNull: true, isNoCase: true, isUnique: true))),
            (key: "icon", type: .TEXT(attribute: (isNotNull: false, isNoCase: true, isUnique: false), defaultValue: nil)),
            (key: "favorite", type: .INTEGER(attribute: (isNotNull: true, isNoCase: true, isUnique: false), defaultValue: 0)),
            (key: "time", type: .TIMESTAMP()),
        ]
    }
}

// MARK: - 公開屬性
extension Bookmark {
    
    /// 表示此書籤是否已被標記為最愛
    ///
    /// 這個屬性會將資料模型中以整數儲存的 `favorite` 值，轉換成較容易使用的 `Bool`
    var isFavorite: Bool {
        Bool(truncating: favorite as NSNumber)
    }
}
