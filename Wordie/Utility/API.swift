//
//  API.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import WWSQLite3Manager

/// 負責與 SQLite 資料庫溝通的單一入口
final class API {
    
    let database: WWSQLite3Manager.Database         // SQLite 資料庫連線物件
    let filename: String                            // 資料庫檔案名稱
    let type: WWSQLite3Manager.SchemeDelegate.Type  // 資料表對應的模型型別
    let historyName: String = "History"             // 記憶單字的資料庫名稱
    
    var tableName: String                           // 單字資料表名稱
    
    /// 建立資料庫操作物件，並初始化資料表
    init(filename: String, tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type) {
        
        self.filename = filename
        self.tableName = tableName
        self.type = type
        
        do {
            database = try WWSQLite3Manager.shared.connect(filename: filename)
            try database.create(tableName: tableName, type: type.self, ifNotExists: true)
            try database.create(tableName: historyName, type: History.self, ifNotExists: true)
        } catch {
            fatalError("資料庫連線 / 建立失敗！")
        }
    }
}

// MARK: - CRUD
extension API: ApiDelegate {
    
    /// 新增一筆單字資料
    ///
    /// - Parameters:
    ///   - wordUI: 要新增的單字資料
    ///
    /// - Throws: 當資料寫入資料庫失敗時拋出錯誤
    func insert(_ wordUI: WordUI) throws {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "english", value: .string(wordUI.word)),
            (key: "phonetic", value: .string(wordUI.reading)),
            (key: "chinese", value: .string(wordUI.chinese)),
        ]
        
        _ = try database.insert(tableName: tableName, itemsArray: [items])
    }
    
    /// 讀取所有單字資料
    ///
    /// 會先從資料表查詢原始資料，再轉換成 `Word` 模型陣列後回傳
    ///
    /// - Returns: 目前資料庫中的所有單字
    func select() -> [WordCard] {

        let words = selectWord().array
        let wordCards = words.compactMap { $0.jsonClass(for: Word.self)?.toWordCard() }
        
        return wordCards
    }
    
    /// 查詢所有歷史單字資料
    ///
    /// 會先從資料表查詢原始資料，再轉換成 `Word` 模型陣列後回傳
    ///
    /// - Returns: 目前歷史資料庫中在該資料庫的所有單字
    func selectHistory() -> [WordCard] {
        
        let sql = """
            SELECT e.*
            FROM \(tableName) e
            JOIN History h ON h.word = e.english
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
    
    /// 更新指定的單字資料
    ///
    /// - Parameters:
    ///   - wordCard: 要新增的單字資料
    ///
    /// - Throws: 當資料更新失敗時拋出錯誤
    func update(_ wordCard: WordCard) throws {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "english", value: .string(wordCard.word)),
            (key: "phonetic", value: .string(wordCard.reading)),
            (key: "chinese", value: .string(wordCard.chinese)),
        ]
        
        let `where`: WWSQLite3Manager.Where = .init().compare("id", .equal, .int(wordCard.id))
        _ = try database.update(tableName: tableName, items: items, where: `where`)
    }
    
    /// 刪除指定 id 的單字資料
    ///
    /// - Parameter id: 欲刪除的單字識別值
    ///
    /// - Throws: 當資料刪除失敗時拋出錯誤
    func delete(id: Int) throws {
        let `where`: WWSQLite3Manager.Where = .init().compare("id", .equal, .int(id))
        try database.delete(tableName: tableName, where: `where`)
    }
    
    /// 取得目前資料庫中所有資料表的 schema 資訊 => 回傳內容會把 sqlite_master 的查詢結果轉成 SqliteMaster 陣列
    func tableSchemas() -> [SqliteMaster] {
        let result = selectSqliteMaster()
        return result.array.compactMap { $0.jsonClass(for: SqliteMaster.self) }.sorted { $0.name > $1.name  }
    }
    
    /// 更新指定單字的難度累積值
    ///
    /// 如果單字尚未存在於歷史資料表中，會先建立一筆預設資料，預設難度值為 `0`，建立後便直接返回，不會在同一次呼叫中再套用難度增減
    ///
    /// - Parameters:
    ///   - word: 要更新難度的單字
    ///   - difficulty: 本次要套用的難度變化
    /// - Throws: 當資料新增或更新失敗時拋出錯誤
    func updateHistory(at word: String, difficulty: WordDifficulty) throws {
                
        guard let history = selectHistoryWord(word) else { try insertHistoryWord(word); return }
        try updateHistory(history, difficulty: difficulty)
    }
}

// MARK: - Private
private extension API {
    
    /// 查詢單字資料表中的所有原始資料
    ///
    /// 此方法只負責執行資料查詢，不處理模型轉換，供內部方法重用
    ///
    /// - Returns: SQLite 查詢結果
    func selectWord() -> WWSQLite3Manager.SelectResult {
        database.select(tableName: tableName, type: type.self)
    }
    
    /// 查詢 SQLite 系統表 `sqlite_master` 中所有類型為 table 的資料 => 也就是列出目前資料庫裡的所有資料表名稱與其 schema 資訊
    func selectSqliteMaster() -> WWSQLite3Manager.SelectResult {
        database.tables()
    }
}

// MARK: - Private (History)
private extension API {
        
    /// 依照單字內容查詢歷史資料
    ///
    /// - Parameter word: 要查詢的單字
    /// - Returns: 如果資料存在，回傳對應的 `History`；否則回傳 `nil`
    func selectHistoryWord(_ word: String) -> History? {
        
        let `where`: WWSQLite3Manager.Where = .init().compare("word", .equal, .text(word))
        let word = database.select(tableName: historyName, type: History.self, where: `where`).array.first
        
        return word?.jsonClass(for: History.self)
    }
    
    /// 新增一筆單字歷史資料
    ///
    /// 新建立的資料會將 `difficulty` 初始化為 `0`
    ///
    /// - Parameter word: 要新增的單字
    /// - Throws: 當資料寫入失敗時拋出錯誤
    func insertHistoryWord(_ word: String) throws {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "word", value: .string(word)),
            (key: "difficulty", value: .int(0)),
        ]
        
        _ = try database.insert(tableName: historyName, itemsArray: [items])
    }
    
    /// 依照指定難度調整既有歷史資料的難度值
    ///
    /// `easy` 會讓難度值減 `1`，`hard` 會讓難度值加 `1`
    ///
    /// - Parameters:
    ///   - history: 要更新的歷史資料
    ///   - difficulty: 要套用的難度變化
    /// - Throws: 當資料更新失敗時拋出錯誤
    func updateHistory(_ history: History, difficulty: WordDifficulty) throws {
        
        var value: Int64 = Int64(history.difficulty)
        
        switch difficulty {
        case .easy: value -= 1
        case .hard: value += 1
        }
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "difficulty", value: .int(value)),
            (key: "time", value: .date(.now)),
        ]
        
        let `where`: WWSQLite3Manager.Where = .init().compare("id", .equal, .int(history.id))
        _ = try database.update(tableName: historyName, items: items, where: `where`)
    }
}
