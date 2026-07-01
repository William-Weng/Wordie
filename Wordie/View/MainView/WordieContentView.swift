//
//  WordieContentView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI
import WWFlipWordCardUI

/// Wordie 主畫面
///
/// 負責顯示單字卡片、翻牌、左右切換與發音按鈕
struct WordieContentView: View {
    
    let words: [WordCard]                                           // 單字資料來源
    let configure: Configure                                        // 一般初始化設定
    
    @Binding var currentIndex: Int                                  // 目前顯示綁定的單字索引
    @Binding var tableNames: [String]                               // 資料表名稱
    @Binding var useHistory: Bool                                   // 是否選到的使用歷史資料
    @Binding var path: NavigationPath
    
    let onTableMenuTap: (String) -> Void                            // 選擇資料表名稱後的動作 (單字, 是否看歷史記錄)
    let onDifficultyMenuTap: (WordCard?, WordDifficulty?) -> Void   // 選擇資料表名稱後的動作 (單字, 單字難度)
    
    @State private var selectedName = ""                            // 選到的資料表名稱
    @State private var isAutoReading = false                        // 翻頁自動跟讀單字
    @State private var difficulty: WordDifficulty?                  // 單字記憶難度
    
    var body: some View {
        
        ZStack {
            background
            
            VStack(spacing: 20) {
                
                titleView
                
                WordieMascotView(image: Image(systemName: configure.icon))
                
                if words.isEmpty {
                    emptyStateView
                        .frame(height: 320)
                        .padding(.horizontal, 28)
                } else {
                    WWFlipWordCardUI(words: flipWords, isAscending: false, currentIndex: $currentIndex, configure: flipWordConfigure) { _, index in
                        readingWord(words[safe: index])
                    }
                    .frame(height: 320)
                    .padding(.horizontal, 28)
                }
                
                WordProgressView(totalCount: words.count, currentIndex: $currentIndex)
                
                HStack {
                    difficultyItems
                        .frame(width: 54, height: 54, alignment: .leading)
                    Spacer()
                    playButton
                    Spacer(minLength: 16)
                    menuItems
                        .frame(width: 54, height: 54, alignment: .trailing)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 28)
            }
            .padding(.bottom, 8)
        }.onChange(of: words.count) {
            clampCurrentIndex()
        }.onChange(of: selectedName) {
            onTableMenuTap(selectedName)
        }.onChange(of: useHistory) {
            onTableMenuTap(selectedName)
        }.onChange(of: difficulty) {
            onDifficultyMenuTap(words[currentIndex], difficulty)
        }
    }
}

// MARK: - 私有屬性
private extension WordieContentView {
    
    /// 翻頁用的設定
    var flipWordConfigure: WWFlipWordCardUI.Configure {
        
        .init(levelColors: WordLevel.dictionary(),
              categoryColors: WordCategory.dictionary(),
              wordFont: FontResolver.shared.word,
              readingFont: FontResolver.shared.reading,
              chineseFont: FontResolver.shared.chinese
        )
    }
    
    /// 翻頁用的Words集合
    var flipWords: [WWFlipWordCardUI.WordCard] {
        
        let flipWords = words.map { word in
            
            let categories = WordCategory.parseTypes(from: word.category).map { $0.name }
            let level = WordLevel(rawValue: word.level.value) ?? .None
            
            return WWFlipWordCardUI.WordCard(id: word.id, word: word.word, reading: word.reading, categories: categories, chinese: word.chinese, level: level.title)
        }

        return flipWords
    }
}

// MARK: - 私有View
private extension WordieContentView {
    
    /// 背景漸層
    var background: some View {
        
        LinearGradient(
            colors: configure.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 標題文字
    var titleView: some View {
        
        Text(configure.title)
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundStyle(.orange)
            .padding(.top, 24)
    }
    
    /// 空狀態內容
    var emptyStateView: some View {
        
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("目前沒有單字")
                .font(.headline)

            Text("先新增一些單字，再開始學習吧。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.12))
        )
    }
    
    /// [資料表選項](https://levelup.gitconnected.com/swiftui-menu-a-little-more-than-just-a-list-of-buttons-dd143ba9f6cf)
    var menuItems: some View {
        
        Menu {
            Button(action: {
                useHistory.toggle()
            }, label: {
                Text("歷史記錄")
            })
            
            Button(action: {
                path.append(Route.bookmarks)
            }, label: {
                Text("書籤記錄")
            })
            
            Picker("單字列表", selection: $selectedName) {
                
                ForEach(tableNames, id: \.self) { name in
                    ZStack {
                        Text(name)
                        Image(systemName: "leaf.fill")
                    }
                    .tag(name)
                }
            }
        } label: {
            Image(systemName: "tablecells.badge.ellipsis")
                .font(.system(size: 26, weight: .semibold))
                .frame(width: 54, height: 54)
                .foregroundStyle(!useHistory ? .blue : .red)
        }
    }
    
    /// 單字記憶難度選項
    var difficultyItems: some View {
        
        Menu {
            Picker("單字難度", selection: $difficulty) {
                ForEach(WordDifficulty.allCases, id: \.self) { difficulty in
                    ZStack {
                        Text(difficulty.rawValue)
                        Image(systemName: difficulty.icon)
                    }
                    .tag(difficulty)
                }
            }
        } label: {
            Image(systemName: "dial.low")
                .font(.system(size: 26, weight: .semibold))
                .frame(width: 54, height: 54)
                .foregroundStyle(difficulty?.color ?? .gray)
        }
    }
    
    /// 單字跟讀功能 (isAutoReading 變為 true / false)    
    var playButton: some View {
        
        WordPlayButton(image: Image(systemName: "play.fill"), isAutoReading: $isAutoReading) {
            guard let word = words[safe: currentIndex] else { return }
            word.speakWord(by: configure.language)
        }.contextMenu {
            Picker("跟讀模式", selection: $isAutoReading) {
                Label("手動跟讀", systemImage: "hand.tap.fill").tag(false)
                Label("自動跟讀", systemImage: "speaker.wave.3.fill").tag(true)
            }
        }
    }
}

// MARK: - 小工具
private extension WordieContentView {
    
    /// 將目前索引限制在有效範圍內
    ///
    /// 當單字陣列是空的時，直接把 `currentIndex` 設為 0，如果索引超出陣列範圍，則修正到最後一筆或第一筆，避免發生越界
    func clampCurrentIndex() {
        
        guard !words.isEmpty else { currentIndex = 0; return }
        
        if currentIndex >= words.count { currentIndex = words.count - 1 }
        if currentIndex < 0 { currentIndex = 0 }
    }
    
    /// 單字自動跟讀功能 for isAutoReading
    /// - Parameter word: 單字片資訊
    func readingWord(_ word: WordCard?) {

        guard isAutoReading,
              let word = word
        else {
            return
        }
                
        word.speakWord(by: configure.language)
    }
}
