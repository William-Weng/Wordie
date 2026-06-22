//
//  WordLevel.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/17.
//

import SwiftUI

/// 日語能力試驗（JLPT）共分 N1～N5 五個級數（N5最簡單、N1最難）
enum WordLevel: Int {
    
    case N5, N4, N3, N2, N1
}

// MARK: - WordLevelDatabase
extension WordLevel: WordLevelDatabase {
    
    var backgroundColor: Color {
        switch self {
        case .N5: .green
        case .N4: .black
        case .N3: .blue
        case .N2: .brown
        case .N1: .red
        }
    }
    
    var value: String {
        switch self {
        case .N5: "N5"
        case .N4: "N4"
        case .N3: "N3"
        case .N2: "N2"
        case .N1: "N1"
        }
    }
}
