//
//  FontLoader.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/12.
//

import UIKit
import CoreText

class FontLoader {
    static let shared = FontLoader()
}

extension FontLoader {
    
    enum CustomError: Error, CustomStringConvertible {
        
        case fontNotFound(path: String)
        case fontLoadFailed(path: String)
        case fontRegisterFailed(path: String, error: CFError)
        case invalidPostScriptName
        case jsonDecodeFailed
        
        var description: String {
            
            switch self {
            case .fontNotFound(let path): return "❌ 找不到字型檔案: \(path)"
            case .fontLoadFailed(let path): return "❌ 無法載入字型: \(path)"
            case .fontRegisterFailed(let path, let error): return "❌ 字型註冊失敗: \(path), \(error)"
            case .invalidPostScriptName: return "❌ 無效的 PostScript 名稱"
            case .jsonDecodeFailed: return "❌ JSON 解碼失敗"
            }
        }
    }
    
    enum FontSource {
        case system(postScriptName: String, size: CGFloat)
        case ttf(path: String, size: CGFloat)
    }
}

extension FontLoader {
    
    // 從 FontSource 建立 Font
    func loadFont(source: FontSource) throws -> UIFont? {
        
        switch source {
        case .system(let postScriptName, let size): return loadSystemFont(name: postScriptName, size: size)
        case .ttf(let ttfPath, let size): return try loadTTFFont(ttfPath: ttfPath, size: size)
        }
    }
    
    // 預設原字型（nil）
    func originalFont() -> UIFont? {
        return nil
    }
}

private extension FontLoader {
    
    // 從字型檔讀取 PostScriptName
    func getPostScriptName(from url: URL) -> String? {
        
        guard let dataProvider = CGDataProvider(url: url as CFURL),
              let cgFont = CGFont(dataProvider)
        else {
            return nil
        }
        
        guard let postScriptName = cgFont.postScriptName else {
            return nil
        }
        
        return String(postScriptName)
    }
    
    // 內部：動態註冊字型
    func loadUIFont(from url: URL, postScriptName: String, size: CGFloat) throws -> UIFont? {
        
        if isFontRegistered(postScriptName: postScriptName) { return .init(name: postScriptName, size: size) }
        
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        
        if !success {
            if let cfError = error?.takeUnretainedValue() {
                throw CustomError.fontRegisterFailed(path: url.lastPathComponent, error: cfError)
            }
        }
        
        return UIFont(name: postScriptName, size: size)
    }
    
    func loadTTFFont(ttfPath: String, size: CGFloat) throws -> UIFont? {
        
        let ttfURL: URL = .documentsDirectory.appendingPathComponent(ttfPath)
        
        guard let postScriptName = getPostScriptName(from: ttfURL) else {
            throw CustomError.invalidPostScriptName
        }
        
        let uiFont = try loadUIFont(from: ttfURL, postScriptName: postScriptName, size: size)
        
        print("✅ 成功載入外部字型: \(postScriptName), size: \(size)")
        return uiFont
    }
    
    // 從系統字型名稱建立 Font
    func loadSystemFont(name: String, size: CGFloat) -> UIFont {
        return .init(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    func isFontRegistered(postScriptName: String) -> Bool {
        let font = UIFont(name: postScriptName, size: 12)
        return font != nil
    }
}
