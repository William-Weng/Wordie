//
//  API.swift
//  Kirie
//
//  Created by William.Weng on 2026/6/16.
//

import WWSQLite3Manager

/// 負責與 SQLite 資料庫溝通的單一入口
final class API {
        
    let database: WWSQLite3Manager.Database         // SQLite 資料庫連線物件
    let tableName: String                           // 單字資料表名稱
    let type: WWSQLite3Manager.SchemeDelegate.Type  // 資料表對應的模型型別
    let filename: String                            // 資料庫檔案名稱
    
    /// 建立資料庫操作物件，並初始化資料表
    init(filename: String, tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type) {
        
        self.filename = filename
        self.tableName = tableName
        self.type = type
        
        do {
            database = try WWSQLite3Manager.shared.connect(filename: filename)
            let sql = try database.create(tableName: tableName, type: type.self, ifNotExists: true)
            print("✨ \(sql)")
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
            (key: "japanese", value: .string(wordUI.word)),
            (key: "kana", value: .string(wordUI.reading)),
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
        
        let words = selectWord().array.compactMap { $0.jsonClass(for: Word.self)?.toWordCard() }
        return words
    }
    
    /// 更新指定的單字資料
    ///
    /// - Parameters:
    ///   - wordCard: 要新增的單字資料
    ///
    /// - Throws: 當資料更新失敗時拋出錯誤
    func update(_ wordCard: WordCard) throws {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "japanese", value: .string(wordCard.word)),
            (key: "kana", value: .string(wordCard.reading)),
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
        selectSqliteMaster().array.compactMap { $0.jsonClass(for: SqliteMaster.self) }
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
        let `where`: WWSQLite3Manager.Where = .init().compare("type", .equal, .text("table"))
        return database.select(tableName: "sqlite_master", type: SqliteMaster.self, where: `where`)
    }
}

