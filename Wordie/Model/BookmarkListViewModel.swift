//
//  BookmarkListViewModel.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI

/// 單字列表的 ViewModel
@Observable
final class BookmarkListViewModel {
    
    var bookmarks: [Bookmark] = []   // 畫面上顯示的單字列表
    
    @ObservationIgnored
    private var api: ApiDelegate
    
    init(api: ApiDelegate) {
        self.api = api
    }
}

// MARK: - 公開函式
extension BookmarkListViewModel {
        
    func loadBookmarks() {
        bookmarks = api.selectBookmark()
    }
    
    func addBookmark(_ title: String, url: String, icon: String) throws {
        try api.insertBookmark(title, url: url, icon: icon)
        loadBookmarks()
    }
    
    func updateBookmark(id: Int, title: String, url: String, icon: String) throws {
        try api.updateBookmark(id: id, title: title, url: url, icon: icon)
        loadBookmarks()
    }
    
    func updateBookmark(id: Int, isFavorite: Bool) throws {
        
        try api.updateBookmark(id: id, isFavorite: isFavorite)
        loadBookmarks()
    }
    
    func deleteBookmark(_ bookmark: Bookmark) throws {
        
        try api.deleteBookmark(id: bookmark.id)
        loadBookmarks()
    }
}
