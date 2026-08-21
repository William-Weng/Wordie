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
    override var dictionaries: [String: String] {
        [
            "Mazii日語詞典": "https://mazii.net/zh-TW/search/word/jatw/\(Self.keyWord)",
            "時雨日中辭典": "https://www.sigure.tw/dict/jp/\(Self.keyWord)",
            "Weblio日語辭典": "https://www.weblio.jp/content/\(Self.keyWord)",
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
    /// => SELECT j.* FROM N3 j JOIN History h ON h.word = j.japanese WHERE japanese LIKE '%あ%' OR kana LIKE '%あ%' AND (category & 4) != 0 ORDER BY h.time DESC
    /// 會先從資料表查詢原始資料，再轉換成 `Word` 模型陣列後回傳
    ///
    /// - Returns: 目前歷史資料庫中在該資料庫的所有單字
    override func selectHistory(from keyword: String, by category: WordCategory?) -> [WordCard] {

        let wordKey = "japanese"
        let subWordKey = "kana"
        var conditions: [String] = []
        
        if !keyword.isEmpty {
            let escapedKeyword = keyword.replacingOccurrences(of: "'", with: "''")
            conditions.append("\(wordKey) LIKE '%\(escapedKeyword)%' OR \(subWordKey) LIKE '%\(escapedKeyword)%'")
        }
        
        if let category {
            conditions.append("(category & \(category.binary)) != 0")
        }
        
        let whereClause = conditions.isEmpty ? "" : "WHERE " + conditions.joined(separator: " AND ")
        
        let sql = "SELECT j.*, h.difficulty FROM \(tableName) j JOIN History h ON h.word = j.\(wordKey) \(whereClause) ORDER BY h.time DESC"
        
        do {
            let dict = try database.query(sql: sql)
            
            return dict.compactMap {
                
                guard let word = $0.jsonClass(for: Word.self) else { return nil }
                
                let diffculty = $0["difficulty"] as? Int64 ?? 0
                return word.toWordCard(diffculty: Int(diffculty))
            }
        } catch {
            return []
        }
    }
    
    /// 搜尋單字並回傳對應的 WordCard 陣列
    /// => SELECT j.* FROM N3 j WHERE japanese LIKE '%あ%' OR kana LIKE '%あ%' AND (category & 4) != 0 ORDER BY japanese
    /// - Parameters:
    ///   - keyword: 要搜尋的關鍵字；若為空字串將不套用文字搜尋條件。此參數會作簡單的單引號轉義以避免基本的 SQL 語法錯誤（但非完全安全的注入防護）
    ///   - category: 可選的詞性篩選（bitmask）。若為 nil 則不套用詞性篩選；若有值，查詢會使用 bitwise AND，回傳「包含該詞性 flag」的紀錄
    /// - Returns: 成功時回傳符合條件的 WordCard 陣列；發生錯誤或查詢失敗時回傳空陣列
    override func selectWord(from keyword: String, by category: WordCategory?) -> [WordCard] {
        
        let wordKey = "japanese"
        let subWordKey = "kana"
        var conditions: [String] = []
        
        if !keyword.isEmpty {
            let escapedKeyword = keyword.replacingOccurrences(of: "'", with: "''")
            conditions.append("\(wordKey) LIKE '%\(escapedKeyword)%' OR \(subWordKey) LIKE '%\(escapedKeyword)%'")
        }
        
        if let category {
            conditions.append("(category & \(category.binary)) != 0")
        }
                
        let whereClause = conditions.isEmpty ? "" : "WHERE " + conditions.joined(separator: " AND ")
        
        let sql = "SELECT j.* FROM \(tableName) j \(whereClause) ORDER BY \(wordKey)"
        
        do {
            let dict = try database.query(sql: sql)
            return dict.compactMap { $0.jsonClass(for: Word.self)?.toWordCard(diffculty: 0) }
        } catch {
            return []
        }
    }
}
