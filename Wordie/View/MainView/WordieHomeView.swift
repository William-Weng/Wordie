//
//  WordieHomeView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import SwiftUI
import WWSafariViewUI
import WWHUDUI

/// Wordie 主畫面
///
/// 此畫面負責：
/// - 載入單字列表資料
/// - 顯示目前的單字內容
/// - 提供新增、編輯與刪除功能
/// - 追蹤目前顯示中的單字索引，讓編輯與刪除能正確作用在當前項目
struct WordieHomeView: View {
    
    let api: API
    let configure: Configure
    
    private let hud: WWHUDUI = .init()
    
    @State private var viewModel: WordListViewModel             // 主畫面使用的 ViewModel，負責管理單字資料
    @State private var path = NavigationPath()                  // 導航路徑
    
    @State private var activeSheet: WordSheet?                  // 目前正在顯示的 sheet 狀態
    @State private var tableNames: [String] = []                // 資料庫的列表名稱
    @State private var isShowingDeleteConfirm = false           // 是否顯示刪除確認對話框
    @State private var isLoading = false                        // 目前正在讀取單字資料
    @State private var useHistory: Bool = false                 // 是否選到的使用歷史資料
    
    @AppStorage("currentIndex") private var currentIndex = 0    // 目前正在顯示的單字索引
    @AppStorage("currnetTable") private var currnetTable = ""   // 選到的資料表名稱
        
    var body: some View {
        
        NavigationStack(path: $path) {
            
            WordieContentView(words: viewModel.words, configure: configure, currentIndex: $currentIndex, currnetTable: $currnetTable, tableNames: $tableNames, useHistory: $useHistory, path: $path) { tablename in
                refreshWords(with: tablename, isHistory: useHistory)
            } onDifficultyMenuTap: { wordCard, difficulty in
                try? updateWordDifficulty(wordCard?.word, difficulty: difficulty)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolBarTitleView
                deleteItem
                dictionaryItem
                editItem
                if !useHistory { addItem }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add, .edit: AddWordView(sheet: sheet, viewModel: viewModel)
                case .dictionary(let wordCard): dictionaryView(with: wordCard)
                }
            }.confirmationDialog("確定要刪除這個單字嗎？", isPresented: $isShowingDeleteConfirm, titleVisibility: .visible) {
                Button("刪除", role: .destructive) { removeWord(with: currentIndex) }
            } message: {
                Text("這個動作無法復原。")
            }.navigationDestination(for: Route.self) { route in
                switch route {
                case .bookmarks: BookmarkPageView(api: api, configure: configure)
                }
            }
        }
        .task {
            hideKeyboard()
            tableNames = formatTablenames()
            api.tableName = currnetTable
            viewModel.reloadWords()
        }
        .loadingOverlay(hud)
        .onChange(of: isLoading) { _, newValue in
            displayHUD(newValue)
        }
    }
    
    /// 初始化設定
    /// - Parameters:
    ///   - api: API功能
    ///   - configure: 一般初始化設定
    init(api: API, configure: Configure) {
        
        self.api = api
        self.configure = configure
        
        _viewModel = State(wrappedValue: WordListViewModel(api: api))
        loadFonts(url: .documentsDirectory, filename: "config.json")
    }
}

// MARK: - Toolbar
private extension WordieHomeView {
    
    /// 中間的標題文字
    @ToolbarContentBuilder
    var toolBarTitleView: some ToolbarContent {
        
        ToolbarItem(placement: .principal) {
            Text(currnetTable)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
    
    /// 左上角刪除按鈕
    ///
    /// 點擊後會顯示刪除確認對話框，並針對目前顯示中的單字進行刪除
    @ToolbarContentBuilder
    var addItem: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                activeSheet = .add
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    /// 右上角新增按鈕
    ///
    /// 點擊後開啟新增單字表單
    @ToolbarContentBuilder
    var editItem: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
            
            Button {
                guard viewModel.words.indices.contains(currentIndex) else { return }
                let currentWord = viewModel.words[currentIndex]
                activeSheet = .edit(currentWord)
            } label: {
                Image(systemName: "pencil")
            }
            .disabled(viewModel.words.isEmpty)
        }
    }
    
    /// 右上角編輯按鈕
    ///
    /// 點擊後會取得目前畫面上顯示的單字，並以編輯模式開啟表單畫面
    @ToolbarContentBuilder
    var deleteItem: some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                guard viewModel.words.indices.contains(currentIndex) else { return }
                isShowingDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
            .disabled(viewModel.words.isEmpty)
        }
    }
    
    /// 解譯單字功能
    @ToolbarContentBuilder
    var dictionaryItem: some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                guard let currentWord = viewModel.words[safe: currentIndex] else { return }
                activeSheet = .dictionary(currentWord)
            } label: {
                Image(systemName: "questionmark.bubble")
                    .renderingMode(.template)
            }
            .tint(.red)
            .disabled(viewModel.words.isEmpty)
        }
    }
}

// MARK: - 私有API
private extension WordieHomeView {
    
    /// 載入外部字型
    ///
    /// 從指定的 URL 讀取 config.json，解析字型配置並初始化全域 Font
    ///
    /// - Parameters:
    ///   - url: 字型檔案所在的基礎路徑（例如：`Bundle.main.resourceURL`）
    ///   - filename: JSON 檔案名稱（例如：`"config.json"`）
    /// 執行流程：
    /// 1. 拼湊 config.json 的完整路徑
    /// 2. 讀取 JSON 檔案數據
    /// 3. 解碼為 FontConfig 模型
    /// 4. 解析字型配置並儲存到 FontResolver.shared
    /// 5. 成功或失敗時打印對應訊息
    ///
    /// - Note: 如果解析失敗，字型會保持預設值（系統字型）
    ///
    /// Example:
    /// ```swift
    /// if let resourceURL = Bundle.main.resourceURL {
    ///     loadFonts(url: resourceURL)
    /// }
    /// ```
    func loadFonts(url: URL, filename: String) {
        
        let jsonURL = url.appendingPathComponent(filename)
        print("🚗 \(jsonURL)")
        
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let config = try JSONDecoder().decode(FontConfig.self, from: jsonData)
            
            try FontResolver.shared.resolveFonts(from: config)
            print("✅ 全域字型初始化成功")
        } catch {
            print("❌ JSON 解析失敗: \(error)")
        }
    }
    
    /// 更新單字 (A1 / B1 / C1)
    /// - Parameters:
    ///   - tableName: 資料表名稱
    ///   - isHistory: 是否看歷史記錄
    func refreshWords(with tableName: String, isHistory: Bool) {
        
        isLoading = true
        currentIndex = 0
        viewModel.words.removeAll()
        viewModel.api.tableName = tableName
        
        Task {
            !isHistory ? viewModel.reloadWords() : viewModel.reloadHistory()
            isLoading = false
        }
    }
    
    /// 把預設的資料表排在前面
    /// - Returns: [String]
    func formatTablenames() -> [String] {
        
        let sqlTablenames = api.tableSchemas().map(\.name).sorted()
        let exceptionName: Set<String> = [History.tableName, Bookmark.tableName, api.tableName]
        
        var tablenames = [api.tableName]
        
        for name in sqlTablenames {
            if exceptionName.contains(name) { continue }
            tablenames.append(name)
        }
        
        return tablenames.reversed()
    }
    
    /// 更新單字難易度
    /// - Parameters:
    ///   - word: 單字
    ///   - difficulty: 難易度
    func updateWordDifficulty(_ word: String?, difficulty: WordDifficulty?) throws {
        
        guard let difficulty = difficulty,
              let word = word
        else {
            return
        }
        
        try api.updateHistory(at: word, difficulty: difficulty)
    }
    
    /// 刪除單字
    /// - Parameter index: 單字序號
    func removeWord(with index: Int) {
        
        let currentWord = viewModel.words[index]
        isLoading = true
        
        Task {
            !useHistory ? try? viewModel.deleteWord(currentWord) : try? viewModel.deleteHistory(currentWord)
            isLoading = false
        }
    }
    
    /// 是否顯示HUD
    func displayHUD(_ enable: Bool) {
        
        if enable {
            hud.display("資料讀取中...")
        } else {
            hud.dismiss(minimumVisibleDuration: 0.5)
        }
    }
    
    /// 解譯單字功能
    func dictionaryView(with wordCard: WordCard) -> some View {
        let url = api.searchWordUrl(wordCard.word)
        return WWSafariViewUI(url: url!).ignoresSafeArea()
    }
}
