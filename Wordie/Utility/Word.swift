//
//  Word.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import Foundation

/// 單字模型 => 用來儲存一個單字的英文、音標與中文翻譯
struct Word: Identifiable {
    
    let id = UUID()         // 每個 Word 都需要一個唯一識別碼 (SwiftUI 會用它來區分不同資料項目)
    let english: String     // 英文單字
    let phonetic: String    // 音標
    let chinese: String     // 中文翻譯
}

// MARK: - 公開屬性
extension Word {
    
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
