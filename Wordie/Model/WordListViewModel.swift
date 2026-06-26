//
//  WordListViewModel.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import SwiftUI

/// 單字列表的 ViewModel
@Observable
final class WordListViewModel {
    
    var words: [WordCard] = []   // 畫面上顯示的單字列表
    
    @ObservationIgnored
    var api: ApiDelegate        // 提供書籤資料存取能力的 API (此屬性不需要被 Observation 系統追蹤，因此使用`@ObservationIgnored` 避免不必要的觀察)
    
    /// 建立單字列表 ViewModel
    init(api: ApiDelegate) {
        self.api = api
    }
}

// MARK: - 公開函式
extension WordListViewModel {
        
    /// 從資料庫重新讀取所有單字，並更新目前清單
    func reloadWords() {
        words = api.select()
    }
    
    /// 新增一筆單字資料到資料庫，並重新載入清單
    ///
    /// - Parameter wordUI: 要新增的單字資料
    ///
    /// - Throws: 當資料寫入失敗時拋出錯誤
    func addWord(_ wordUI: WordUI) throws {
        try api.insert(wordUI)
        reloadWords()
    }
    
    /// 更新指定單字內容，並重新載入清單
    /// 
    /// - Parameters:
    ///   - id: 要更新資料的ID
    ///   - wordUI: 更新的資料
    /// - Throws: 當資料更新失敗時拋出錯誤
    func updateWord(id: Int, wordUI: WordUI) throws {
        
        let wordCard: WordCard = .init(id: id, word: wordUI.word, reading: wordUI.reading, category: wordUI.category, chinese: wordUI.chinese, level: WordLevel.allCases[0])
        try api.update(wordCard)
        
        reloadWords()
    }
    
    /// 刪除指定單字，並重新載入清單
    ///
    /// - Parameter wordCard: 欲刪除的單字資料
    ///
    /// - Throws: 當資料刪除失敗時拋出錯誤
    func deleteWord(_ wordCard: WordCard) throws {
                
        try api.delete(id: wordCard.id)
        reloadWords()
    }
}

// MARK: - History
extension WordListViewModel {
    
    /// 從資料庫重新讀取所有單字記錄，並更新目前清單
    func reloadHistory() {
        words = api.selectHistory()
    }
    
    /// 刪除指定單字，並重新載入清單
    ///
    /// - Parameter wordCard: 欲刪除的單字資料
    ///
    /// - Throws: 當資料刪除失敗時拋出錯誤
    func deleteHistory(_ wordCard: WordCard) throws {
        try api.deleteHistory(word: wordCard.word)
        reloadHistory()
    }
}
