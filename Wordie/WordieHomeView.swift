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
    
    @StateObject private var viewModel = WordListViewModel()    // 主畫面使用的 ViewModel，負責管理單字資料
    
    @State private var activeSheet: WordSheet?                  // 目前正在顯示的 sheet 狀態
    @State private var currentIndex = 0                         // 目前正在顯示的單字索引
    @State private var isShowingDeleteConfirm = false           // 是否顯示刪除確認對話框
    
    var body: some View {
        
        NavigationStack {
            
            WordieContentView(words: viewModel.words, currentIndex: $currentIndex)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    deleteItem
                    addItem
                    editItem
                }
                .sheet(item: $activeSheet) { sheet in
                    AddWordView(sheet: sheet, viewModel: viewModel)
                }.confirmationDialog(
                    "確定要刪除這個單字嗎？",
                    isPresented: $isShowingDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("刪除", role: .destructive) {
                        try? viewModel.delete(currentIndex)
                    }
                } message: {
                    Text("這個動作無法復原。")
                }
        }
        .task {
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
}
