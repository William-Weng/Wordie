//
//  API.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import Foundation
import WWSQLite3Manager

final class API {
    
    static let shared = API()
    
    private let database: WWSQLite3Manager.Database
    private let tableName: String
    private let type: WWSQLite3Manager.SchemeDelegate.Type
    private let filename: String
    
    init() {
        
        filename = "Wordie.db"
        tableName = "english"
        type = Word.self

        do {
            database = try WWSQLite3Manager.shared.connect(filename: filename)
            try database.create(tableName: tableName, type: type.self, ifNotExists: true)
            
            print(database.fileURL)
                        
        } catch {
            fatalError()
        }
    }
}

extension API {
    
    func insert(english: String, phonetic: String, chinese: String) {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "english", value: .string(english)),
            (key: "phonetic", value: .string(phonetic)),
            (key: "chinese", value: .string(chinese)),
        ]
        
        _ = try? database.insert(tableName: tableName, itemsArray: [items])
    }
    
    func select() -> [Word] {
                
        let words = selectWord().array.compactMap { $0.jsonClass(for: Word.self) }
        return words
    }
    
    func update(id: Int, english: String, phonetic: String, chinese: String) {
        
        let items: [WWSQLite3Manager.InsertItem] = [
            (key: "english", value: .string(english)),
            (key: "phonetic", value: .string(phonetic)),
            (key: "chinese", value: .string(chinese)),
        ]
        
        let `where`: WWSQLite3Manager.Where = .init().and("id", .equal, .int(id))
        _ = try? database.update(tableName: tableName, items: items, where: `where`)
    }
}

private extension API {
    
    func selectWord() -> WWSQLite3Manager.SelectResult {
        database.select(tableName: tableName, type: type.self)
    }
}

