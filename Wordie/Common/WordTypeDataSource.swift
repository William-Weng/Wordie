//
//  WordCategoryDataSource.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/26.
//

import SwiftUI

// 詞性DataSource
protocol WordCategoryDataSource: CaseIterable, Identifiable, Hashable {
    
    var id: Int { get }
    var name: String { get }            // 中文名稱
    var background: Color { get }       // 背景色
    var binary: Int { get }             // 二進制數值
    var binaryString: String { get }    // 二進制文字
    
    /// 將詞性二進制值 => [any WordTypeDataSource]
    static func parseTypes(from value: Int) -> [Self]
    
    /// 快速轉成 ["名稱": "顏色"]
    static func dictionary() -> [String: Color]
    
    /// 將詞性組二進位值組合
    static func combine(_ types: [WordCategory]) -> Int
}
