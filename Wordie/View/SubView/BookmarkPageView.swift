//
//  BookmarkPageView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI
import WWSafariViewUI

/// 書籤列表主畫面。
///
/// 此視圖負責顯示所有書籤資料，並提供：
/// - 開啟書籤內容
/// - 新增與編輯書籤
/// - 刪除書籤
/// - 切換最愛狀態
struct BookmarkPageView: View {
    
    private let configure: Configure                        // 畫面外觀設定
    
    @State private var viewModel: BookmarkListViewModel     // 管理書籤列表資料與操作邏輯的 ViewModel
    @State private var selectedURL: IdentifiableURL?        // 目前要開啟的網址項目 (當此值不為 `nil` 時，會以全畫面方式顯示 Safari 視圖)
    @State private var currentBookmark: Bookmark?           // 目前選取中的書籤資料
    @State private var activeSheet: BookmarkSheet?          // 目前要顯示的工作表內容 (當此值不為 `nil` 時，會顯示新增或編輯書籤畫面)
    
    var body: some View {
        
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                
                List {
                    ForEach(viewModel.bookmarks, id: \.id) { bookmark in
                        
                        BookmarkRow(bookmark: bookmark) {
                            guard let url = URL(string: bookmark.url) else { selectedURL = nil; return }
                            selectedURL = .init(url: url)
                        } onFavoriteTap: { bookmark in
                            try? viewModel.updateBookmark(id: bookmark.id, isFavorite: !bookmark.isFavorite)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            swipeActionsMaker(for: bookmark)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                        .listRowSeparator(.visible)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("書籤記錄")
        .toolbar {
            addItem
        }
        .sheet(item: $activeSheet) { sheet in
            AddBookmarkView(sheet: sheet, viewModel: viewModel)
        }
        .fullScreenCover(item: $selectedURL) { item in
            WWSafariViewUI(url: item.url)
                .ignoresSafeArea()
        }
    }
    
    /// 建立書籤列表主畫面
    ///
    /// - Parameters:
    ///   - api: 提供書籤資料查詢與異動功能的 API
    ///   - configure: 畫面外觀設定
    init(api: API, configure: Configure) {
        
        self.configure = configure
        _viewModel = State(wrappedValue: BookmarkListViewModel(api: api))
        viewModel.reloadBookmarks()
    }
}

// MARK: - 小工具
private extension BookmarkPageView {
    
    /// 畫面的背景漸層視圖
    var backgroundView: some View {
        
        LinearGradient(
            colors: configure.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    /// 新增書籤按鈕的工具列項目
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
    
    /// 建立指定書籤的滑動操作按鈕
    ///
    /// - Parameter bookmark: 要操作的書籤資料
    @ViewBuilder
    func swipeActionsMaker(for bookmark: Bookmark) -> some View {
        
        Button {
            activeSheet = .edit(bookmark)
        } label: {
            Label("編輯", systemImage: "pencil")
        }
        .tint(Color.green)
        
        Button(role: .destructive) {
           try? viewModel.deleteBookmark(bookmark)
        } label: {
            Label("刪除", systemImage: "trash")
        }
    }
}

