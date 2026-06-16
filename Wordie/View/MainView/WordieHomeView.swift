//
//  WordieHomeView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import SwiftUI

/// Wordie 主畫面
///
/// 此畫面負責：
/// - 載入單字列表資料
/// - 顯示目前的單字內容
/// - 提供新增、編輯與刪除功能
/// - 追蹤目前顯示中的單字索引，讓編輯與刪除能正確作用在當前項目
struct WordieHomeView: View {
    
    let api: API                                                // API功能
    let configure: Configure                                    // 一般初始化設定

    @StateObject private var viewModel = WordListViewModel()    // 主畫面使用的 ViewModel，負責管理單字資料
    
    @State private var activeSheet: WordSheet?                  // 目前正在顯示的 sheet 狀態
    @State private var currentIndex = 0                         // 目前正在顯示的單字索引
    @State private var isShowingDeleteConfirm = false           // 是否顯示刪除確認對話框
    
    var body: some View {
        
        NavigationStack {
            
            WordieContentView(words: viewModel.words, configure: configure, currentIndex: $currentIndex)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    deleteItem
                    if #available(iOS 26.0, *) { intellisenseItem }
                    editItem
                    addItem
                }
                .sheet(item: $activeSheet) { sheet in

                    switch sheet {
                    case .add, .edit: AddWordView(sheet: sheet, viewModel: viewModel)
                    case .intellisense: if #available(iOS 26.0, *) { IntelliSenseWordView(sheet: sheet, viewModel: viewModel, instructions: configure.instructions)  }
                    }
                    
                }.confirmationDialog(
                    "確定要刪除這個單字嗎？",
                    isPresented: $isShowingDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("刪除", role: .destructive) {
                        let currentWord = viewModel.words[currentIndex]
                        try? viewModel.deleteWord(currentWord)
                    }
                } message: {
                    Text("這個動作無法復原。")
                }
        }
        .task {
            loadFonts(url: .documentsDirectory, filename: "config.json")
            viewModel.api = api
            viewModel.loadWords()
        }
    }
}

// MARK: - Toolbar
private extension WordieHomeView {
    
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
    
    @ToolbarContentBuilder
    var intellisenseItem: some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                guard viewModel.words.indices.contains(currentIndex) else { return }
                let currentWord = viewModel.words[currentIndex]
                activeSheet = .intellisense(currentWord)
            } label: {
                Image(systemName: "apple.intelligence")
                    .renderingMode(.template)
            }
            .tint(.red)
            .disabled(viewModel.words.isEmpty)
        }
    }
}

// MARK: - Toolbar
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
}
