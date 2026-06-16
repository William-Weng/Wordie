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
        
        if let word = try resolveFont(detail: config.font.english, size: 48) { self.word = word }
        if let reading = try resolveFont(detail: config.font.phonetic, size: 28) { self.reading = reading }
        if let chinese = try resolveFont(detail: config.font.chinese, size: 32) { self.chinese = chinese }
    }
}

// MARK: - private
private extension FontResolver {
    
    /// 解析單一字型
    ///
    /// 根據 FontDetail 設定，載入系統字型或 TTF 字型。
    ///
    /// - Parameter detail: 字型詳細設定（FontDetail）
    /// - Parameter size: 預設字型大小（如果 config 沒有 size）
    /// - Returns: SwiftUI Font 物件
    /// - Throws: `WWFontLoader.CustomError` 如果載入失敗
    func resolveFont(detail: FontDetail, size: CGFloat) throws -> Font? {
        
        let size = detail.size ?? size
        
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
    
    /// 將 UIFont 轉換為 SwiftUI Font
    ///
    /// 輔助函式，將 WWFontLoader 回傳的 UIFont 轉換為 SwiftUI 的 Font
    ///
    /// - Parameter uiFont: UIFont 物件
    /// - Returns: SwiftUI Font 物件（如果 uiFont 不為 nil）
    func swiftUIFont(_ uiFont: UIFont?) -> Font? {
        guard let uiFont = uiFont else { return nil }
        return Font(uiFont)
    }
}
