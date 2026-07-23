//
//  API.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/16.
//

import Foundation
import WWSQLite3Manager

/// 負責與 SQLite 資料庫溝通的單一入口
final class API: BaseAPI {
    
    // 線上字典URL
    override var dictionies: [String: String] {
        [
            "Mazii 日語詞典": "https://mazii.net/zh-TW/search/word/jatw/\(keyWord)",
            "時雨日中辭典": "https://www.sigure.tw/dict/jp/\(keyWord)",
            "語源由来辞典": "https://gogen-yurai.jp/?s=\(keyWord)",
        ]
    }
        
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
            (key: "category", value: .int(Int64(wordUI.category))),
            (key: "level", value: .int(Int64(wordUI.level))),
        ]
        
        try database.insert(tableName: tableName, itemsArray: [items])
    }
    
    /// 更新指定的單字資料
    ///
    /// - Parameters:
    ///   - wordCard: 要新增的單字資料
    ///
    /// - Throws: 當資料更新失敗時拋出錯誤
    override func update(_ wordCard: WordCard) throws {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "japanese", value: .string(wordCard.word)),
            (key: "kana", value: .string(wordCard.reading)),
            (key: "chinese", value: .string(wordCard.chinese)),
            (key: "category", value: .int(Int64(wordCard.category))),
            (key: "level", value: .int(Int64(wordCard.level.value))),
        ]
        
        let `where`: WWSQLite3Manager.Where = .init().compare("id", .equal, .int(wordCard.id))
        try database.update(tableName: tableName, items: items, where: `where`)
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
    
    /// 搜尋包含關鍵字的單字
    /// - Parameters:
    ///   - keyword: 關鍵字
    /// - Returns: 目前資料庫中在包含關鍵字的所有單字
    override func selectWord(from keyword: String) -> [WordCard] {
        
        let sql = """
            SELECT e.*
            FROM \(tableName) e
            WHERE kana LIKE '%\(keyword)%' OR japanese LIKE '%\(keyword)%'
            ORDER BY kana
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
