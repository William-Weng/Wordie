//
//  FontResolver.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/12.
//

import SwiftUI
import WWFontLoader

/// 字型解析器
///
/// 負責解析字型配置（FontConfig），並初始化全域 Font 變數，支援系統內建字型（name）和外部的 TTF 字型（ttf），並可自訂字型大小（size）。
///
/// ## 特性
/// - 全域 Font 存取（`FontResolver.shared.english`）
/// - 自動解析配置（`FontConfig`）
/// - 支援預設大小（如果 config 沒有 size）
/// - 錯誤處理（`throws`）
class FontResolver {
    
    static let shared = FontResolver()
    
    var word: Font = .system(size: 48, weight: .bold, design: .rounded)
    var reading: Font = .system(size: 28, weight: .medium, design: .monospaced)
    var chinese: Font = .system(size: 32, weight: .bold, design: .rounded)
    
    var searchWord: Font = .system(size: 24, weight: .bold, design: .rounded)
    var searchReading: Font = .system(size: 14, weight: .medium, design: .monospaced)
    var searchChinese: Font = .system(size: 16, weight: .bold, design: .rounded)
    
    private let loader = WWFontLoader.shared
}

// MARK: - internal
extension FontResolver {
    
    /// 解析字型配置
    ///
    /// 從 FontConfig 讀取字型設定，並更新全域 Font 變數。
    ///
    /// - Parameter config: 字型配置（FontConfig）
    /// - Throws: `WWFontLoader.CustomError` 如果載入失敗
    func resolveFonts(from config: FontConfig) throws {
        
        if let word = try resolveFont(detail: config.font.word, defaultSize: 48) { self.word = word }
        if let reading = try resolveFont(detail: config.font.reading, defaultSize: 28) { self.reading = reading }
        if let chinese = try resolveFont(detail: config.font.chinese, defaultSize: 32) { self.chinese = chinese }
        
        if let searchWord = try resolveSearchFont(detail: config.font.word, size: 24) { self.searchWord = searchWord }
        if let searchReading = try resolveSearchFont(detail: config.font.reading, size: 14) { self.searchReading = searchReading }
        if let searchChinese = try resolveSearchFont(detail: config.font.chinese, size: 16) { self.searchChinese = searchChinese }
    }
}

// MARK: - private
private extension FontResolver {
    
    /// 解析單一字型
    ///
    /// 根據 FontDetail 設定，載入系統字型或 TTF 字型
    ///
    /// - Parameter detail: 字型詳細設定（FontDetail）
    /// - Parameter defaultSize: 預設字型大小（如果 config 沒有 size）
    /// - Returns: SwiftUI Font 物件
    /// - Throws: `WWFontLoader.CustomError` 如果載入失敗
    func resolveFont(detail: FontDetail, defaultSize: CGFloat) throws -> Font? {
        
        let size = detail.size ?? defaultSize
        
        if let postScriptName = detail.name {
            let source = WWFontLoader.FontSource.system(postScriptName: postScriptName, size: size)
            return try swiftUIFont(loader.loadFont(source: source))
        }
        
        if let ttfFileName = detail.ttf {
            
            let url: URL = .documentsDirectory.appendingPathComponent(ttfFileName)
            let source = WWFontLoader.FontSource.ttf(url: url, size: size)
            
            return try swiftUIFont((loader.loadFont(source: source)))
        }
        
        return nil
    }
    
    /// 解析單一字型 for 單字搜尋
    ///
    /// 根據 FontDetail 設定，載入系統字型或 TTF 字型
    ///
    /// - Parameter detail: 參照的字型詳細設定
    /// - Parameter size: 字型大小
    /// - Returns: SwiftUI Font 物件
    /// - Throws: `WWFontLoader.CustomError` 如果載入失敗
    func resolveSearchFont(detail: FontDetail, size: CGFloat) throws -> Font? {
        let newDetail: FontDetail = .init(name: detail.name, ttf: detail.ttf, size: size)
        return try resolveFont(detail: newDetail, defaultSize: size)
    }
    
    /// 將 UIFont 轉換為 SwiftUI Font
    ///
    /// 輔助函式，將 WWFontLoader 回傳的 UIFont 轉換為 SwiftUI 的 Font
    ///
    /// - Parameter uiFont: UIFont 物件
    /// - Returns: SwiftUI Font 物件（如果 uiFont 不為 nil）
    func swiftUIFont(_ uiFont: UIFont?) -> Font? {
        guard let uiFont = uiFont else { return nil }
        return .init(uiFont)
    }
}
