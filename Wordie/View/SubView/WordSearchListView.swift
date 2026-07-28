//
//  WordSearchListView.swift
//  Wordie
//
//  Created by William on 2026/7/22.
//

import SwiftUI
import WWHUDUI

/// 單字搜尋頁
struct WordSearchListView: View {
    
    private let configure: Configure                    // 外部注入的設定資料，用來初始化此畫面需要的參數或行為
    private let hud: WWHUDUI = .init()                  // 顯示載入中、成功、失敗等提示訊息的 HUD 元件
    
    @State private var viewModel: WordListViewModel     // 畫面的資料與商業邏輯控制中心，負責管理單字清單、查詢與狀態更新
    
    @State private var searchText = ""                  // 搜尋框目前的文字內容
    @State private var activeSheet: WordSheet?          // 目前要顯示的 Sheet 類型
    @State private var category: WordCategory?          // 目前選擇的詞性分類
    
    var body: some View {
        
        ZStack {
            
            backgroundView
            
            List(viewModel.words, id: \.id) { word in
                
                itemViewCard(word)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        word.speakWord(by: configure.language)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        swipeActionsMaker(for: word)
                    }
                    .padding(.horizontal, 8)
            }
            .navigationTitle(title)
            .searchable(text: $searchText, placement: .toolbar, prompt: "單字搜尋")
            .toolbar {
                categoryItems
            }
            .listStyle(.plain)
            .sheet(item: $activeSheet) { sheet in
                AddWordView(sheet: sheet, viewModel: viewModel)
            }
            .onChange(of: searchText) { _, newValue in
                displayHUD {
                    viewModel.selectWord(from: newValue, by: category)
                }
            }.onChange(of: category) { _, newValue in
                displayHUD {
                    viewModel.selectWord(from: searchText, by: newValue)
                }
            }
        }.loadingOverlay(hud)
    }
        
    /// 建立單字搜尋列表畫面
    ///
    /// - Parameters:
    ///   - configure: 畫面外觀設定
    ///   - api: API 共有規範
    init(configure: Configure, api: ApiDelegate) {
        self.configure = configure
        viewModel = .init(api: api)
        viewModel.reloadWords()
    }
}

// MARK: - 私有屬性
private extension WordSearchListView {
    
    /// 目前畫面顯示的標題
    ///
    /// 當使用者已選擇特定詞性分類時，回傳該分類的名稱；若尚未指定分類，則回傳 API 對應的資料表名稱
    var title: String {
        category?.name ?? viewModel.api.tableName
    }
}

// MARK: - 子視圖
private extension WordSearchListView {
    
    /// 畫面背景漸層
    var backgroundView: some View {
        
        LinearGradient(
            colors: configure.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 單字卡片背景
    var itemBackgroundView: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.white.opacity(0.28))
    }
    
    /// 單字卡片邊框
    var itemBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(.black.opacity(0.22), lineWidth: 1)
    }
    
    /// 詞性篩選選單
    ///
    /// 這個選單提供兩種操作：
    /// - 從 `WordCategory.allCases` 中選擇指定的詞性分類
    /// - 清除目前的分類條件，改為「不限定」
    ///
    /// 選取某個詞性後，`category` 會更新為對應的 `WordCategory`；選擇「不限定」時，`category` 會被設為 `nil`
    var categoryItems: some View {
        
        Menu {
            
            Picker("詞性列表", selection: $category) {
                
                ForEach(WordCategory.allCases, id: \.self) { category in
                    
                    ZStack {
                        Text(category.name)
                        Image(systemName: "leaf.fill")
                    }
                    .tag(Optional(category))
                }
            }
            
            Button {
                category = nil
            } label: {
                Text("不限定")
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
            
        } label: {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 32, height: 32)
        }
    }
    
    /// 建立指定單搜字尋的滑動操作按鈕
    ///
    /// - Parameter bookmark: 要操作的書籤資料
    @ViewBuilder
    func swipeActionsMaker(for word: WordCard) -> some View {
        
        Button {
            activeSheet = .edit(word)
        } label: {
            Label("編輯", systemImage: "pencil")
        }
        .tint(Color.green)
        
        Button(role: .destructive) {
            try? viewModel.deleteWord(word)
        } label: {
            Label("刪除", systemImage: "trash")
        }
    }
}
 
// MARK: - 文字元件
private extension WordSearchListView {
    
    /// 單一單字卡片
    func itemViewCard(_ word: WordCard) -> some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            VStack(alignment: .leading, spacing: 6) {
                
                if configure.isAscending {
                    wordItem(word)
                    if !word.reading.isEmpty { readingItem(word) }
                } else {
                    if !word.reading.isEmpty { readingItem(word) }
                    wordItem(word)
                }
            }
            
            Spacer(minLength: 8)
            chineseItem(word)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            itemBackgroundView
        }
        .overlay {
            itemBorder
        }
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
    
    /// 顯示主要單字
    func wordItem(_ word: WordCard) -> some View {
        
        Text(word.word)
            .font(FontResolver.shared.searchWord)
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .layoutPriority(1)
    }
    
    /// 顯示讀音
    func readingItem(_ word: WordCard) -> some View {
        
        Text(word.reading)
            .font(FontResolver.shared.searchReading)
            .foregroundStyle(.gray)
            .lineLimit(1)
    }
    
    /// 顯示中文意思
    func chineseItem(_ word: WordCard) -> some View {
        
        Text(word.chinese)
            .font(FontResolver.shared.searchChinese)
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
    }
}

// MARK: - 私有API
private extension WordSearchListView {
    
    /// 顯示HUD
    /// - Parameter action: 要執行的動作功能
    func displayHUD(action: () -> Void) {
        
        hud.display("資料讀取中...")
        
        action()
        
        Task {
            hud.dismiss(minimumVisibleDuration: 0.75)
        }
    }
}

