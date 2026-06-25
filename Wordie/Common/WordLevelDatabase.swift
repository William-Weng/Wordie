//
//  WordLevelDatabase.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/18.
//

import SwiftUI

/// 將各語系等級取得文字 / 底色 => 多專案共用
protocol WordLevelDatabase: CaseIterable {
    
    var value: String { get }           // 單字值
    var backgroundColor: Color { get }  // 背景色
}
