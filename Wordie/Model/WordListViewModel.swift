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
    
    var words: [WordCard] = []          // 畫面上顯示的單字列表
    var category: WordCategory?         // 要過濾的詞性
    var keyword: String = ""            // 要搜尋的關鍵字
    
    @ObservationIgnored
    var api: ApiDelegate                // 提供書籤資料存取能力的 API (此屬性不需要被 Observation 系統追蹤，因此使用`@ObservationIgnored` 避免不必要的觀察)
    
    @ObservationIgnored
    private var lastQuery: WordQuery?   // 記錄上一次的搜尋文字 + 詞性 (防止重複搜尋)
    
    /// 建立單字列表 ViewModel
    init(api: ApiDelegate) {
        self.api = api
    }
}

// MARK: - 公開函式
extension WordListViewModel {
    
    /// 從資料庫重新讀取所有單字，並更新目前清單
    func reloadWords() {
        
        let newKeyword = keyword.removeWhitespacesAndNewlines
        
        if newKeyword.isEmpty && category == nil {
            words = api.select()
        } else {
            words = api.selectWord(from: newKeyword, by: category)
        }
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
        
        let level = WordLevel(rawValue: wordUI.level) ?? .None
        let wordCard: WordCard = .init(id: id, word: wordUI.word, reading: wordUI.reading, category: wordUI.category, chinese: wordUI.chinese, level: level, diffculty: 0)
        
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
    
    /// 搜尋單字並回傳對應的 WordCard 陣列 (不會重複搜尋)
    /// - Parameters:
    ///   - useHistory: 是否搜尋歷史單字
    /// - Returns: 成功時回傳符合條件的 WordCard 陣列；發生錯誤或查詢失敗時回傳空陣列
    func selectWord(useHistory: Bool) {
        
        let newKeyword = keyword.removeWhitespacesAndNewlines
        let query = WordQuery(keyword: newKeyword, category: category, useHistory: useHistory)
        
        guard lastQuery != query else { return }
        lastQuery = query
        
        if useHistory { words = api.selectHistory(from: newKeyword, by: category); return }
        
        if newKeyword.isEmpty && category == nil {
            words = api.select()
        } else {
            words = api.selectWord(from: newKeyword, by: category)
        }
    }
}

// MARK: - History
extension WordListViewModel {
    
    /// 從資料庫重新讀取所有單字記錄，並更新目前清單
    func reloadHistory() {
        words = api.selectHistory(from: keyword, by: category)
    }
    
    /// 刪除指定單字，並重新載入清單
    func deleteHistory(_ wordCard: WordCard) throws {
        try api.deleteHistory(word: wordCard.word)
        reloadHistory()
    }
    
    /// 將指定 id 的 history 記錄 difficulty 重設為 0
    func resetHistoryDifficulty(_ wordCard: WordCard) throws {
        try api.resetHistoryDifficulty(at: wordCard.word)
        reloadHistory()
    }
    
    /// 新增 / 更新指定單字在的 difficulty，完成後重新載入原資料
    ///
    /// - Parameters:
    ///   - difficulty: 要增加的單字記憶難度類型
    ///   - wordCard: 要更新的單字資料
    /// - Throws: 當更新資料庫失敗時拋出錯誤
    func updateWordDifficulty(_ difficulty: WordDifficulty, at wordCard: WordCard) throws {
        try api.updateHistory(at: wordCard.word, difficulty: difficulty)
        reloadWords()
    }
    
    /// 更新指定單字在 history 中的 difficulty，完成後重新載入歷史資料
    ///
    /// - Parameters:
    ///   - difficulty: 要增加的單字記憶難度類型
    ///   - wordCard: 要更新的單字資料
    /// - Throws: 當更新資料庫失敗時拋出錯誤
    func updateHistoryDifficulty(_ difficulty: WordDifficulty, at wordCard: WordCard) throws {
        try api.updateHistory(at: wordCard.word, difficulty: difficulty)
        reloadHistory()
    }
}
