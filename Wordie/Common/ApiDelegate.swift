//
//  APIDelegate.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/16.
//

import Foundation
import WWSQLite3Manager

/// API 共有規範
protocol ApiDelegate {
    
    var database: WWSQLite3Manager.Database { get }         // SQLite 資料庫連線物件
    var historyName: String { get }                         // 記憶單字的資料庫名稱
    var tableName: String { get set }                       // 單字資料表名稱
    var type: WWSQLite3Manager.SchemeDelegate.Type { get }  // 資料表對應的模型型別
    var filename: String { get }                            // 資料庫檔案名稱
    
    /// 建立資料庫操作物件，並初始化資料表
    init(filename: String, tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type)
    
    /// 新增一筆單字資料
    func insert(_ wordUI: WordUI) throws
    
    /// 讀取所有單字資料
    func select() -> [WordCard]
    
    /// 更新指定的單字資料
    func update(_ wordCard: WordCard) throws
    
    /// 刪除指定 id 的單字資料
    func delete(id: Int) throws
    
    /// 取得目前資料庫中所有資料表的 schema 資訊
    func tableSchemas() -> [SqliteMaster]
    
    /// 更新指定單字的難度累積值
    func updateHistory(at word: String, difficulty: WordDifficulty) throws
}
