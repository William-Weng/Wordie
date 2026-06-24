//
//  SqliteMaster.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/18.
//

import Foundation
import WWSQLite3Manager

/// SQL資料表訊息模型
struct SqliteMaster: Codable {
    
    let type: String
    let name: String
    let tbl_name: String
    let rootpage: Int
    let sql: String
}

/// 包含`id`的URL
struct IdentifiableURL: Hashable, Identifiable {
    
    let id = UUID()
    let url: URL
}

