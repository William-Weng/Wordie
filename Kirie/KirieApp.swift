//
//  KirieApp.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/16.
//

import SwiftUI

@main
struct KirieApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            WordieHomeView(
                api: .init(
                    filename: "Kirie.db",
                    tableName: "japanese",
                    type: JapaneseWord.self
                ),
                configure: .init(
                    title: "Kirie",
                    icon: "hare.fill",
                    language: "ja-JP",
                    colors: [
                        Color(red: 0.99, green: 0.94, blue: 0.95),
                        Color(red: 0.98, green: 0.90, blue: 0.92)
                    ])
            )
        }
    }
}
