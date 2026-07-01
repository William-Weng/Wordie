//
//  WordLevel.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/17.
//

import SwiftUI

/// 日語能力試驗（JLPT）共分 N1～N5 五個級數（N5最簡單、N1最難）
enum WordLevel: Int {
    
    case None, N5, N4, N3, N2, N1
}

// MARK: - WordLevelDatabase
extension WordLevel {
    
    /// 快速轉成 ["名稱": "顏色"]
    /// - Returns: [String: Color]
    static func dictionary() -> [String: Color] {
        Dictionary(uniqueKeysWithValues: Self.allCases.map { ($0.title, $0.background) })
    }
}

// MARK: - WordLevelDatabase
extension WordLevel: WordLevelDatabase {
    
    // Identifiable
    var id: Int { rawValue }
    
    /// 原始數值
    var value: Int { rawValue }

    /// 顯示文字
    var title: String {
        
        switch self {
        case .None: "N/A"
        case .N5: "N5"
        case .N4: "N4"
        case .N3: "N3"
        case .N2: "N2"
        case .N1: "N1"
        }
    }
    
    /// 背景色
    var background: Color {
        
        switch self {
        case .None: .clear
        case .N5: .green
        case .N4: .black
        case .N3: .blue
        case .N2: .brown
        case .N1: .red
        }
    }
}
