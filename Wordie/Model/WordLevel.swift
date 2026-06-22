//
//  WordLevel.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/17.
//

import SwiftUI

/// 歐洲共同語言參考標準（CEFR）分為 6 大級別（A1最簡單、C2最難）
enum WordLevel: Int {
    case A2, B1, B2, C1, C2
}

// MARK: - WordLevelDatabase
extension WordLevel: WordLevelDatabase {
    
    var value: String {
        
        switch self {
        case .A2: "A2"
        case .B1: "B1"
        case .B2: "B2"
        case .C1: "C1"
        case .C2: "C2"
        }
    }
    
    var backgroundColor: Color {
        
        switch self {
        case .A2: .green
        case .B1: .blue
        case .B2: .orange
        case .C1: .red
        case .C2: .pink
        }
    }
}
