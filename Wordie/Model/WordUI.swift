//
//  WordUI.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import Foundation

/// 暫停單字模型
struct WordUI {
    
    let english: String     // 英文單字
    let phonetic: String    // 音標
    let chinese: String     // 中文翻譯
}

// MARK: - 公開屬性
extension WordUI {
    
    /// 預設單字資料
    /// 可以直接用 `Word.samples` 取得範例資料陣列。
    static var samples: [Self] {
         [
            .init(english: "apple", phonetic: "/ˈæpəl/", chinese: "蘋果"),
            .init(english: "beautiful", phonetic: "/ˈbjuːtəfəl/", chinese: "美麗的"),
            .init(english: "challenge", phonetic: "/ˈtʃælɪndʒ/", chinese: "挑戰"),
            .init(english: "dream", phonetic: "/driːm/", chinese: "夢想"),
            .init(english: "elephant", phonetic: "/ˈɛlɪfənt/", chinese: "大象")
        ]
    }
}


