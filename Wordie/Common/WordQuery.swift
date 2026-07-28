//
//  WordQuery.swift
//  Wordie
//
//  Created by William.Weng on 2026/7/28.
//

import Foundation

/// 單字搜尋記錄
struct WordQuery: Equatable {
    
    let keyword: String             // 關鍵字
    let category: WordCategory?     // 詞性
}
