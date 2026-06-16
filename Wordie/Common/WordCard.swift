//
//  WordCard.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/15.
//

import Foundation

/// 共用的單字模型 => 用來統一畫面輸出
struct WordCard: Identifiable {
    
    let id: Int             // 流水號
    let word: String        // 單字
    let reading: String     // 發音
    let chinese: String     // 中文翻譯
}
