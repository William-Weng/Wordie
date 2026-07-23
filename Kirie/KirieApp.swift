//
//  KirieApp.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/16.
//

import SwiftUI

// MARK: - 日文單字學習版
@main
struct KirieApp: App {
    
    private let instructions: String = """
        我是位優秀的日文老師，會幫人解說日文單字，主要以正體中文解說，會分析單字的詞性，比如說：自動詞 / 他動詞 / 五段活用動詞 / い形容詞 / な形容詞 / 名詞…等的特性，也會有簡單中日對應的例句可以參考，長話短說，最多三個例句，以下是簡單的例子：
        ```md
        # 食事 (しょくじ) or サラリーマン (Salaryman)
        
        1. [名詞] 進餐; 吃飯; 餐點; 伙食
        > 例句：毎日の食事は健康の基本です。
        > 假名：まいにちのしょくじは けんこうのきほんです。
        > 翻譯：每日的餐點是健康的基礎。
        ```
        """
    
    var body: some Scene {
        
        WindowGroup {
            WordieHomeView(
                api: .init(
                    filename: "Kirie.db",
                    tableName: "Japanese",
                    type: Word.self
                ),
                configure: .init(
                    title: "Kirie",
                    icon: "hare.fill",
                    language: "ja-JP",
                    colors: [
                        Color(red: 0.80, green: 0.90, blue: 0.80),
                        Color(red: 0.72, green: 0.84, blue: 0.72)
                    ],
                    isAscending: false,
                    instructions: instructions
                )
            )
        }
    }
}
