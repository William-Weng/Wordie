//
//  BookmarkListViewModel.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI

/// 管理書籤列表資料與操作邏輯的 ViewModel。
///
/// 此型別負責：
/// - 載入書籤列表
/// - 新增書籤
/// - 更新書籤內容
/// - 更新最愛狀態
/// - 刪除書籤
@Observable
final class BookmarkListViewModel {
    
    private(set) var bookmarks: [Bookmark] = []  // 目前畫面上顯示的書籤列表
    
    @ObservationIgnored
    private var api: ApiDelegate    // 提供書籤資料存取能力的 API (此屬性不需要被 Observation 系統追蹤，因此使用`@ObservationIgnored` 避免不必要的觀察)
    
    /// 建立書籤列表 ViewModel
    init(api: ApiDelegate) {
        self.api = api
    }
}

// MARK: - 公開函式
extension BookmarkListViewModel {
        
    /// 重新載入所有書籤，並更新畫面使用的列表資料
    func reloadBookmarks() {
        bookmarks = api.selectBookmark()
    }
    
    /// 新增一筆書籤，完成後重新載入列表
    ///
    /// - Parameters:
    ///   - title: 書籤標題。
    ///   - url: 書籤網址。
    ///   - icon: 書籤圖示字串。
    /// - Throws: 當新增書籤失敗時拋出錯誤。[web:21][web:23]
    func addBookmark(title: String, url: String, icon: String) throws {
        try api.insertBookmark(title, url: url, icon: icon)
        reloadBookmarks()
    }
    
    /// 更新指定書籤的基本資料，完成後重新載入列表
    ///
    /// - Parameters:
    ///   - id: 要更新的書籤 ID
    ///   - title: 更新後的書籤標題
    ///   - url: 更新後的書籤網址
    ///   - icon: 更新後的書籤圖示字串
    /// - Throws: 當更新書籤失敗時拋出錯誤
    func updateBookmark(id: Int, title: String, url: String, icon: String) throws {
        try api.updateBookmark(id: id, title: title, url: url, icon: icon)
        reloadBookmarks()
    }
    
    /// 更新指定書籤的最愛狀態，完成後重新載入列表
    ///
    /// - Parameters:
    ///   - id: 要更新的書籤 ID
    ///   - isFavorite: 更新後的最愛狀態
    /// - Throws: 當更新最愛狀態失敗時拋出錯誤
    func updateBookmark(id: Int, isFavorite: Bool) throws {
        
        try api.updateBookmark(id: id, isFavorite: isFavorite)
        reloadBookmarks()
    }
    
    /// 刪除指定書籤，完成後重新載入列表
    ///
    /// - Parameter bookmark: 要刪除的書籤資料
    /// - Throws: 當刪除書籤失敗時拋出錯誤
    func deleteBookmark(_ bookmark: Bookmark) throws {
        
        try api.deleteBookmark(id: bookmark.id)
        reloadBookmarks()
    }
}
