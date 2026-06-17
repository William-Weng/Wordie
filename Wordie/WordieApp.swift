//
//  WordieApp.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

@main
struct WordieApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            WordieHomeView(
                api: .init(
                    filename: "Wordie.db",
                    tableName: "english",
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
                    instructions: "你是位英文老師，會幫人解說英文單字"
                )
            )
        }
    }
}
