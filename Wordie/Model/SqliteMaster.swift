//
//  SqliteMaster.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/18.
//

import Foundation
import WWSQLite3Manager

/// SQLite 系統資料表的欄位資訊模型
///
/// 對應 `sqlite_master` 查詢結果中的單筆資料
struct SqliteMaster: Codable {
    
    let type: String        // 物件類型，例如 `table`、`index`、`view` 或 `trigger`
    let name: String        // 物件名稱
    let tbl_name: String    // 所屬資料表名稱
    let rootpage: Int       // B-Tree 根頁面的頁碼
    let sql: String         // 建立此物件的 SQL 語句
}

/// 具備唯一識別值的 URL 模型
///
/// 適合用於 SwiftUI 清單或導覽資料來源，讓每個 URL 項目都能符合`Identifiable` 的需求
struct IdentifiableURL: Hashable, Identifiable {
    
    let id = UUID()         // 此 URL 項目的唯一識別值
    let url: URL            // 實際的 URL
}

