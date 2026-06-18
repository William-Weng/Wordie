//
//  WordListViewModel.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import SwiftUI

/// 單字列表的 ViewModel
final class WordListViewModel: ObservableObject {
    
    @Published var words: [WordCard] = []   // 畫面上顯示的單字列表
    
    var api: ApiDelegate!
}

// MARK: - 公開函式
extension WordListViewModel {
    
    /// 從資料庫讀取所有單字，並更新目前清單
    func loadWords() {
        words = api.select()
    }
    
    /// 新增一筆單字資料到資料庫，並重新載入清單
    ///
    /// - Parameter wordUI: 要新增的單字資料
    ///
    /// - Throws: 當資料寫入失敗時拋出錯誤
    func addWord(_ wordUI: WordUI) throws {
        try api.insert(wordUI)
        loadWords()
    }
    
    /// 更新指定單字內容，並重新載入清單
    /// 
    /// - Parameters:
    ///   - id: 要更新資料的ID
    ///   - wordUI: 更新的資料
    /// - Throws: 當資料更新失敗時拋出錯誤
    func updateWord(id: Int, wordUI: WordUI) throws {
        
        let wordCard: WordCard = .init(id: id, word: wordUI.word, reading: wordUI.reading, chinese: wordUI.chinese, level: WordLevel.allCases[0])
        try api.update(wordCard)
        
        loadWords()
    }
    
    /// 刪除指定單字，並重新載入清單
    ///
    /// - Parameter wordCard: 欲刪除的單字資料
    ///
    /// - Throws: 當資料刪除失敗時拋出錯誤
    func deleteWord(_ wordCard: WordCard) throws {
        
        guard let api = api else { return }
        
        try api.delete(id: wordCard.id)
        loadWords()
    }
    
    /// 取得當前全資料表名稱
    /// - Returns: [資料表名稱]
    func tablenames() -> [String]{
        api.tableSchemas().map { $0.name }.sorted()
    }
}
