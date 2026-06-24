//
//  API.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/16.
//

import WWSQLite3Manager

/// 負責與 SQLite 資料庫溝通的單一入口
final class API: BaseAPI {
    
    /// 新增一筆單字資料
    ///
    /// - Parameters:
    ///   - wordUI: 要新增的單字資料
    ///
    /// - Throws: 當資料寫入資料庫失敗時拋出錯誤
    override func insert(_ wordUI: WordUI) throws {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "japanese", value: .string(wordUI.word)),
            (key: "kana", value: .string(wordUI.reading)),
            (key: "chinese", value: .string(wordUI.chinese)),
        ]
        
        _ = try database.insert(tableName: tableName, itemsArray: [items])
    }
    
    /// 查詢所有歷史單字資料
    ///
    /// 會先從資料表查詢原始資料，再轉換成 `Word` 模型陣列後回傳
    ///
    /// - Returns: 目前歷史資料庫中在該資料庫的所有單字
    override func selectHistory() -> [WordCard] {
        
        let sql = """
            SELECT j.*
            FROM \(tableName) j
            JOIN History h ON h.word = j.japanese
            ORDER BY h.time DESC
            """
        
        do {
            let dict = try database.query(sql: sql)
            let words = dict.compactMap { $0.jsonClass(for: Word.self)?.toWordCard() }
            
            return words
        } catch {
            return []
        }
    }
}
