//
//  WordieApp.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

// MARK: - 英文單字學習版
@main
struct WordieApp: App {
    
    private let instructions: String = """
        我是位優秀的英文老師，會幫人解說英文單字，主要以正體中文解說，會分析單字的詞性，比如說：動詞 / 形容詞 / 介詞 / 名詞…等的特性，也會有簡單中英對應的例句可以參考，以下是簡單的例子：
        ```md
        whole [hol]
        
        1. adj. 全部的
        > 例句：He spent a whole morning preparing for the test.
        > 翻譯：他花了一整個早上準備考試。
        ```
        """

    var body: some Scene {
        
        WindowGroup {
            WordieHomeView(
                api: .init(
                    filename: "Wordie.db",
                    tableName: "English",
                    type: Word.self
                ),
                configure: .init(
                    title: "Wordie",
                    icon: "bird.fill",
                    language: "en-US",
                    colors: [
                        Color(red: 0.98, green: 0.92, blue: 0.76),
                        Color(red: 0.95, green: 0.88, blue: 0.70)
                    ],
                    isAscending: true,
                    instructions: instructions
                )
            )
        }
    }
}
