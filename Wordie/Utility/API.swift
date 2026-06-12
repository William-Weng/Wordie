//
//  API.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import WWSQLite3Manager

/// 負責與 SQLite 資料庫溝通的單一入口
final class API {
    
    static let shared = API()                               // 全域共用的 API 實例。
    
    private let database: WWSQLite3Manager.Database         // SQLite 資料庫連線物件
    private let tableName: String                           // 單字資料表名稱
    private let type: WWSQLite3Manager.SchemeDelegate.Type  // 資料表對應的模型型別
    private let filename: String                            // 資料庫檔案名稱
    
    /// 建立資料庫操作物件，並初始化資料表
    init() {
        
        filename = "Wordie.db"
        tableName = "english"
        type = Word.self

        do {
            database = try WWSQLite3Manager.shared.connect(filename: filename)
            try database.create(tableName: tableName, type: type.self, ifNotExists: true)
        } catch {
            fatalError("資料庫連線 / 建立失敗！")
        }
    }
}

// MARK: - CRUD
extension API {
    
    /// 新增一筆單字資料
    ///
    /// - Parameters:
    ///   - english: 英文單字內容
    ///   - phonetic: 單字音標
    ///   - chinese: 中文解釋
    ///
    /// - Throws: 當資料寫入資料庫失敗時拋出錯誤
    func insert(english: String, phonetic: String, chinese: String) throws {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "english", value: .string(english)),
            (key: "phonetic", value: .string(phonetic)),
            (key: "chinese", value: .string(chinese)),
        ]
        
        _ = try database.insert(tableName: tableName, itemsArray: [items])
    }
    
    /// 讀取所有單字資料
    ///
    /// 會先從資料表查詢原始資料，再轉換成 `Word` 模型陣列後回傳
    ///
    /// - Returns: 目前資料庫中的所有單字
    func select() -> [Word] {
                
        let words = selectWord().array.compactMap { $0.jsonClass(for: Word.self) }
        return words
    }
    
    /// 更新指定 id 的單字資料
    ///
    /// - Parameters:
    ///   - id: 欲更新的單字識別值
    ///   - english: 更新後的英文單字
    ///   - phonetic: 更新後的音標
    ///   - chinese: 更新後的中文解釋
    ///
    /// - Throws: 當資料更新失敗時拋出錯誤
    func update(id: Int, english: String, phonetic: String, chinese: String) throws {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "english", value: .string(english)),
            (key: "phonetic", value: .string(phonetic)),
            (key: "chinese", value: .string(chinese)),
        ]
        
        let `where`: WWSQLite3Manager.Where = .init().compare("id", .equal, .int(id))
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
}

