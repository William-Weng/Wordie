//
//  WordLevelDatabase.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/18.
//

import SwiftUI

/// 將各語系等級取得文字 / 底色 => 多專案共用
protocol WordLevelDatabase: CaseIterable, Identifiable {
    
    var value: Int { get }              // 單字等級
    var title: String { get }           // 等級顯示文字
    var backgroundColor: Color { get }  // 背景色
}
