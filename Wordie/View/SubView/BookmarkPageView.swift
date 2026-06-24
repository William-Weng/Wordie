//
//  BookmarkPageView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI

struct BookmarkPageView: View {
    
    private let configure: Configure
    
    @Binding var path: NavigationPath
    
    @State private var viewModel: BookmarkListViewModel
    @State private var selectedURL: IdentifiableURL?
    @State private var currentBookmark: Bookmark?
    
    var body: some View {
        
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        
                        ForEach(viewModel.bookmarks.indices, id: \.self) { index in
                                                        
                            BookmarkRow(bookmark: $viewModel.bookmarks[index]) {
                                guard let url = URL(string: viewModel.bookmarks[index].url) else { selectedURL = nil; return }
                                selectedURL = .init(url: url)
                            } onFavoriteTap: { bookmark in
                                try? viewModel.api.updateBookmark(id: bookmark.id, isFavorite: bookmark.isFavorite)
                            }
                            
                            Divider()
                                .overlay(.black.opacity(0.12))
                                .padding(.leading, 24)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("書籤記錄")
        .fullScreenCover(item: $selectedURL) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
    }
    
    init(api: API, configure: Configure, path: Binding<NavigationPath>) {
        
        self.configure = configure
        _path = path
        _viewModel = State(wrappedValue: BookmarkListViewModel(api: api))
        viewModel.bookmarks = viewModel.api.selectBookmark()
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
}

