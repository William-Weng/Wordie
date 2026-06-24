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
    var api: ApiDelegate
    
    init(api: ApiDelegate) {
        self.api = api
    }
}
