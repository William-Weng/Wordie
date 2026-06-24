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
    var tableName: String { get set }                       // 單字資料表名稱
    var type: WWSQLite3Manager.SchemeDelegate.Type { get }  // 資料表對應的模型型別
    var filename: String { get }                            // 資料庫檔案名稱
    
    /// 建立資料庫操作物件，並初始化資料表
    init(filename: String, tableName: String, type: WWSQLite3Manager.SchemeDelegate.Type)
    
    /// 取得目前資料庫中所有資料表的 schema 資訊
    func tableSchemas() -> [SqliteMaster]
    
    /// 讀取所有單字資料
    func select() -> [WordCard]
    
    /// 查詢所有歷史單字資料
    func selectHistory() -> [WordCard]
    
    /// - Returns: 目前資料庫中的所有書籤資料
    func selectBookmark() -> [Bookmark]
    
    /// 新增一筆單字資料
    func insert(_ wordUI: WordUI) throws
    
    /// 新增一筆書籤資料
    func insertBookmark(_ title: String, url: String, icon: String) throws
    
    /// 更新指定的單字資料
    func update(_ wordCard: WordCard) throws
    
    /// 更新指定單字的難度累積值
    func updateHistory(at word: String, difficulty: WordDifficulty) throws
        
    /// 更新指定的書籤內容
    func updateBookmark(id: Int, title: String, url: String, icon: String) throws
    
    /// 更新指定的書籤是否常用開關
    func updateBookmark(id: Int, isFavorite: Bool) throws
    
    /// 刪除指定 id 的單字資料
    func delete(id: Int) throws
    
    /// 刪除指定單字的歷史資料
    func deleteHistory(word: String) throws
    
    /// 刪除指定 id 的書籤資料
    func deleteBookmark(id: Int) throws
}
