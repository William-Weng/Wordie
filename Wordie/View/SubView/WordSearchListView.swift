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
    @State private var useHistory = false               // 是否搜尋單字歷史
    @State private var activeSheet: WordSheet?          // 目前要顯示的 Sheet 類型
    
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
                        trailingSwipeActions(for: word)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        leadingSwipeActions(for: word)
                    }
                    .padding(.horizontal, 8)
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "單字搜尋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolBarTitleView
                historyButton
                categoryItems
            }
            .listStyle(.plain)
            .sheet(item: $activeSheet) { sheet in
                AddWordView(sheet: sheet, viewModel: viewModel)
            }
            .onChange(of: searchText) { _, newValue in
                viewModel.keyword = newValue
                viewModel.selectWord(useHistory: useHistory)
            }.onChange(of: viewModel.category) { _, newValue in
                displayHUD {
                    viewModel.category = newValue
                    viewModel.selectWord(useHistory: useHistory)
                }
            }.onChange(of: useHistory) { _, newValue in
                viewModel.selectWord(useHistory: newValue)
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
        viewModel.category?.name ?? viewModel.api.tableName
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
    
    /// 中間的標題文字
    @ToolbarContentBuilder
    var toolBarTitleView: some ToolbarContent {
        
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
    
    /// 詞性篩選選單
    ///
    /// 這個選單提供兩種操作：
    /// - 從 `WordCategory.allCases` 中選擇指定的詞性分類
    /// - 清除目前的分類條件，改為「不限定」
    ///
    /// 選取某個詞性後，`category` 會更新為對應的 `WordCategory`；選擇「不限定」時，`category` 會被設為 `nil`
    ///
    @ToolbarContentBuilder
    var categoryItems: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
            
            Menu {
                
                Picker("詞性列表", selection: $viewModel.category) {
                    
                    ForEach(WordCategory.allCases, id: \.self) { category in

                        VStack {
                            Text(category.name)
                            Image(systemName: "leaf.fill")
                        }
                        .tag(Optional(category))
                    }
                }
                
                Button {
                    viewModel.category = nil
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
    }
    
    /// 搜尋歷史單字的開關
    @ToolbarContentBuilder
    var historyButton: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
            
            Button(action: {
                useHistory.toggle()
            }, label: {
                if useHistory {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 32, height: 32)
                }
            })
        }
    }
    
    /// 根據目前畫面模式，回傳對應的右側滑動操作
    ///
    /// - Parameter word: 目前要操作的單字資料
    /// - Returns: 一組 trailing swipe actions；一般模式顯示編輯與刪除，歷史模式顯示重設與刪除
    @ViewBuilder
    func trailingSwipeActions(for word: WordCard) -> some View {
        
        if !useHistory {
            generalSwipeActions(for: word)
        } else {
            historySwipeActions(for: word)
        }
    }
    
    @ViewBuilder
    func leadingSwipeActions(for word: WordCard) -> some View {
        updateDifficultyActions(for: word)
    }
}

// MARK: - Swipe元件
private extension WordSearchListView {
    
    /// 一般單字列表使用的右側滑動操作
    ///
    /// - Parameter word: 目前要操作的單字資料
    /// - Returns: 包含編輯與刪除的 swipe actions
    @ViewBuilder
    func generalSwipeActions(for word: WordCard) -> some View {
        
        Button {
            activeSheet = .edit(word)
        } label: {
            Image(systemName: "pencil")
        }
        .tint(.seaGreen)
        
        Button(role: .destructive) {
            try? viewModel.deleteWord(word)
        } label: {
            Image(systemName: "trash")
        }
        .tint(.darkRed)
    }
    
    /// 歷史紀錄列表使用的右側滑動操作
    ///
    /// - Parameter word: 目前要操作的歷史資料
    /// - Returns: 包含重設 badge 與刪除歷史紀錄的 swipe actions
    @ViewBuilder
    func historySwipeActions(for word: WordCard) -> some View {
        
        Button {
            try? viewModel.resetHistoryDifficulty(word)
        } label: {
            Image(systemName: "arrow.counterclockwise")
        }
        .tint(.seaGreen)

        Button(role: .destructive) {
            try? viewModel.deleteHistory(word)
        } label: {
            Image(systemName: "trash")
        }
        .tint(.darkRed)
    }
    
    /// 提供更新單字 difficulty 的滑動操作
    ///
    /// - Parameter word: 目前要更新難度的單字資料
    /// - Returns: 包含標記困難與標記簡單的操作按鈕
    @ViewBuilder
    func updateDifficultyActions(for word: WordCard) -> some View {
        
        Button {
            updateDifficulty(.hard, at: word)
        } label: {
            Image(systemName: "brain.head.profile")
        }
        .tint(.darkRed)
        
        Button {
            updateDifficulty(.easy, at: word)
        } label: {
            Image(systemName: "hand.thumbsup.fill")
        }
        .tint(.lightBlue)
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
    
    /// 顯示主要單字 / 難度
    func wordItem(_ word: WordCard) -> some View {
        
        HStack(alignment: .center, spacing: 6) {
            
            Text(word.word)
                .font(FontResolver.shared.searchWord)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .layoutPriority(1)
            
            if word.diffculty != 0 {
                difficultyBadge(word.diffculty)
            }
        }
    }
    
    /// 顯示單字難度的 badge
    ///
    /// - Parameter diffculty: 難度值，正數顯示紅色，0 或負數顯示灰色；負數會轉成正值顯示
    /// - Returns: 一個固定 24x24、大致垂直置中的難度標籤
    func difficultyBadge(_ difficulty: Int) -> some View {
        
        let color: Color = (difficulty > 0) ? .darkRed : .lightBlue
        let value = (difficulty > 0) ? difficulty : difficulty * -1
        
        return Text("\(value)")
            .font(.caption.bold())
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .offset(y: 2)
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
    
    /// 更新指定單字卡的難度等級
    /// - Parameters:
    ///   - difficulty: 要設定的難度等級（WordDifficulty 枚舉）
    ///   - word: 目標單字卡物件（WordCard）
    func updateDifficulty(_ difficulty: WordDifficulty, at word: WordCard) {
        
        if !useHistory {
            try? viewModel.updateWordDifficulty(difficulty, at: word)
        } else {
            try? viewModel.updateHistoryDifficulty(difficulty, at: word)
        }
    }
}

