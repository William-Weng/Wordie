//
//  Constant.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import Foundation
import SwiftUI

/// 新增 / 編輯單字時使用的 sheet 狀態
enum WordSheet: Identifiable {
    case add                            // 新增單字
    case edit(WordCard)                 // 編輯指定單字
    case dictionary(WordCard, String)   // 網頁字典 (單字, 字典名稱)
    case ai(WordCard)                   // Apple Intelligence
}

/// 新增 / 編輯單字時使用的 sheet 狀態
enum BookmarkSheet: Identifiable {
    case add                            // 新增書籤
    case edit(Bookmark)                 // 編輯指定書籤
}

/// 單字片滑動方向
enum CardAwayDirection: CGFloat {
    case left = -1                  // 向左滑
    case right = 1                  // 向右滑
}

/// 單字記憶難度
enum WordDifficulty: String, CaseIterable {
    case easy = "簡單"
    case hard = "難"
}

/// [Navigation路徑](https://www.appcoda.com.tw/swiftui-navigation/)
enum Route: Hashable {
    case bookmarks              // 好看書籤
}

// MARK: - 公開屬性
extension WordSheet {
    
    /// sheet(item:) 用的唯一id
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let wordCard): return "edit-\(wordCard.id)"
        case .dictionary(let wordCard, let key): return "dictionary-\(key)-\(wordCard.id)"
        case .ai(let wordCard): return "ai-\(wordCard.id)"
        }
    }
    
    /// 畫面標題
    var title: String {
        switch self {
        case .add: return "新增單字"
        case .edit: return "編輯單字"
        case .dictionary: return "線上字典"
        case .ai: return "AI字典"
        }
    }
    
    /// 確認按鈕使用的 SF Symbol
    var buttonIcon: String {
        switch self {
        case .add: return "plus"
        case .edit: return "arrow.triangle.2.circlepath"
        case .dictionary(_, _): return "character.book.closed.fill"
        case .ai(_): return "apple.intelligence"
        }
    }
}

// MARK: - 公開屬性
extension BookmarkSheet {
    
    /// sheet(item:) 用的唯一 id
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let bookmark): return "edit-\(bookmark.id)"
        }
    }
    
    /// 畫面標題
    var title: String {
        switch self {
        case .add: return "新增書籤"
        case .edit: return "編輯書籤"
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

// MARK: - 公開屬性
extension WordDifficulty {
    
    /// 系統圖示名稱
    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .hard: return "flame.fill"
        }
    }
    
    /// 系統圖示顏色
    var color: Color {
        switch self {
        case .easy: return .blue
        case .hard: return .red
        }
    }
}
