//
//  BookmarkPageView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI

struct BookmarkPageView: View {
    
    private let configure: Configure
        
    @State private var viewModel: BookmarkListViewModel
    @State private var selectedURL: IdentifiableURL?
    @State private var currentBookmark: Bookmark?
    @State private var activeSheet: BookmarkSheet?
    
    var body: some View {
        
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                
                List {
                    ForEach($viewModel.bookmarks, id: \.id) { $bookmark in
                        
                        BookmarkRow(bookmark: $bookmark) {
                            guard let url = URL(string: bookmark.url) else { selectedURL = nil; return }
                            selectedURL = .init(url: url)
                        } onFavoriteTap: { bookmark in
                            try? viewModel.updateBookmark(id: bookmark.id, isFavorite: bookmark.isFavorite)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            
                            Button {
                                activeSheet = .edit(bookmark)
                            } label: {
                                Label("編譯", systemImage: "pencil")
                            }
                            .tint(Color.green)
                            
                            Button(role: .destructive) {
                               try? viewModel.deleteBookmark(bookmark)
                            } label: {
                                Label("刪除", systemImage: "trash")
                            }
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
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
    }
    
    init(api: API, configure: Configure) {
        
        self.configure = configure
        _viewModel = State(wrappedValue: BookmarkListViewModel(api: api))
        viewModel.loadBookmarks()
    }
}

private extension BookmarkPageView {
    
    var backgroundView: some View {
        
        LinearGradient(
            colors: configure.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

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
}

