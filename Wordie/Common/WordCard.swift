//
//  WordCard.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/15.
//

import Foundation

/// 共用的單字模型 => 用來統一畫面輸出
struct WordCard: Identifiable {
    
    // 單字發音服務單例
    private static let speechService = SpeechService()
    
    let id: Int                         // 流水號
    let word: String                    // 單字
    let reading: String                 // 發音
    let category: Int                   // 單字詞性 (對應 WordType)
    let chinese: String                 // 中文翻譯
    let level: any WordLevelDatabase    // 單字等級
}

// MARK: - Public
extension WordCard {
    
    /// 播放單字發音
    /// - Parameters:
    ///   - language: 語音語言代碼，例如 "en-US"、"en-GB"
    func speakWord(by language: String) {
        Self.speechService.speak(word, language: language)
    }
}
