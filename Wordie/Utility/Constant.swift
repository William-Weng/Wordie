//
//  Constant.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import Foundation

/// 新增 / 編輯單字時使用的 sheet 狀態
enum WordSheet: Identifiable {
    case add                // 新增單字
    case edit(WordCard)     // 編輯指定單字
}

// MARK: - 公開屬性
extension WordSheet {
    
    /// sheet(item:) 用的唯一 id
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let word): return "edit-\(word.id)"
        }
    }
    
    /// 畫面標題
    var title: String {
        switch self {
        case .add: return "新增單字"
        case .edit: return "編輯單字"
        }
    }
    
    /// 確認按鈕使用的 SF Symbol
    var buttonIcon: String {
        switch self {
        case .add: return "plus"
        case .edit: return "arrow.triangle.2.circlepath"
        }
    }
}
