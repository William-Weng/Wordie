//
//  WordListViewModel.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import SwiftUI

final class WordListViewModel: ObservableObject {
    
    @Published var words: [Word] = []
}

// MARK: - 公開函式
extension WordListViewModel {
    
    /// 從資料庫讀取所有單字
    func loadWords() {
        words = API.shared.select()
    }
    
    /// 新增一筆單字資料到資料庫，並重新載入清單
    /// - Parameter wordUI: 要新增的單字資料
    func addWord(_ wordUI: WordUI) throws {
        try API.shared.insert(english: wordUI.english, phonetic: wordUI.phonetic, chinese: wordUI.chinese)
        loadWords()
    }
    
    /// 更新指定 ID 的單字內容，並重新載入清單
    /// - Parameters:
    ///   - id: 單字資料的識別編號
    ///   - wordUI: 更新後的單字資料
    func updateWord(_ word: Word) throws {
        try API.shared.update(id: word.id, english: word.english, phonetic: word.phonetic, chinese: word.chinese)
        loadWords()
    }
}
