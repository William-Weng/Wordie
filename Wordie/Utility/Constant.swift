//
//  Constant.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import Foundation

enum WordSheet: Identifiable {
    case add
    case edit(Word)
}

extension WordSheet {
    
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let word): return "edit-\(word.id)"
        }
    }
    
    var title: String {
        switch self {
        case .add: return "新增單字"
        case .edit: return "編輯單字"
        }
    }
    
    var buttonIcon: String {
        switch self {
        case .add: return "plus"
        case .edit: return "checkmark"
        }
    }
}
