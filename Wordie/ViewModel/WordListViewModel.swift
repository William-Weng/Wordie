//
//  WordListViewModel.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import SwiftUI

/// 單字列表的 ViewModel
final class WordListViewModel: ObservableObject {
    
    @Published var words: [Word] = []   // 畫面上顯示的單字列表
}

// MARK: - 公開函式
extension WordListViewModel {
    
    /// 從資料庫讀取所有單字，並更新目前清單
    func loadWords() {
        words = API.shared.select()
    }
    
    /// 新增一筆單字資料到資料庫，並重新載入清單
    ///
    /// - Parameter wordUI: 要新增的單字資料
    ///
    /// - Throws: 當資料寫入失敗時拋出錯誤
    func addWord(_ wordUI: WordUI) throws {
        try API.shared.insert(english: wordUI.english, phonetic: wordUI.phonetic, chinese: wordUI.chinese)
        loadWords()
    }
    
    /// 更新指定單字內容，並重新載入清單
    ///
    /// - Parameter word: 更新後的完整單字資料
    ///
    /// - Throws: 當資料更新失敗時拋出錯誤
    func updateWord(_ word: Word) throws {
        try API.shared.update(id: word.id, english: word.english, phonetic: word.phonetic, chinese: word.chinese)
        loadWords()
    }
    
    /// 刪除指定單字，並重新載入清單
    ///
    /// - Parameter word: 欲刪除的單字資料
    ///
    /// - Throws: 當資料刪除失敗時拋出錯誤
    func deleteWord(_ word: Word) throws {
        try API.shared.delete(id: word.id)
        loadWords()
    }
}
