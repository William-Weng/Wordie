//
//  FontResolver.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/12.
//

import SwiftUI

class FontResolver {
    
    static let shared = FontResolver()
    
    var english: Font = .system(size: 48, weight: .bold, design: .rounded)
    var phonetic: Font = .system(size: 28, weight: .medium, design: .monospaced)
    var chinese: Font = .system(size: 32, weight: .bold, design: .rounded)
    
    private let loader = FontLoader.shared
    
    func resolveFonts(from config: FontConfig) throws {
        
        if let english = try resolveFont(detail: config.font.english, size: 48) { self.english = english }
        if let phonetic = try resolveFont(detail: config.font.phonetic, size: 28) { self.phonetic = phonetic }
        if let chinese = try resolveFont(detail: config.font.chinese, size: 32) { self.chinese = chinese }
    }
}

extension FontResolver {
    
    func resolveFont(detail: FontDetail, size: CGFloat) throws -> Font? {
        
        let size = detail.size ?? size
        
        if let postScriptName = detail.name {
            let source = FontLoader.FontSource.system(postScriptName: postScriptName, size: size)
            return try swiftUIFont(loader.loadFont(source: source))
        }
        
        if let ttfFileName = detail.ttf {
            let source = FontLoader.FontSource.ttf(path: ttfFileName, size: size)
            return try swiftUIFont((loader.loadFont(source: source)))
        }
        
        return swiftUIFont(loader.originalFont())
    }
    
    func swiftUIFont(_ uiFont: UIFont?) -> Font? {
        guard let uiFont = uiFont else { return nil }
        return Font(uiFont)
    }
}
