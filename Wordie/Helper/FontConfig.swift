//
//  FontConfig.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/12.
//

import Foundation

/// 字型配置
///
/// 從 JSON 文件讀取字型配置，包含英語、音標和中文的字型設定。
///
/// ## JSON 結構
/// ```json
/// {
///   "Font": {
///     "english": {
///       "name": "Bradley Hand",
///       "size": 42
///     },
///     "phonetic": {},
///     "chinese": {
///       "ttf": "jf-openhuninn-2.1.ttf",
///       "size": 42
///     }
///   }
/// }
/// ```
struct FontConfig: Codable {
    
    let font: FontDetails       // 字型詳細資訊

    /// JSON 編碼鍵值
    enum CodingKeys: String, CodingKey {
        case font = "Font"      // JSON 使用大寫 "Font"
    }
}

/// 字型詳細資訊
///
/// 包含英語、音標和中文三種字型的具体設定
struct FontDetails: Codable {
    
    let word: FontDetail        // 英語字型設定
    let reading: FontDetail     // 音標字型設定
    let chinese: FontDetail     // 中文字型設定
}

/// 字型詳細設定
///
/// 定義單一字型的名稱、來源檔案和大小，如果 `name` / `ttf` 同時有值，會以 `name` 為主
///
/// ## 選項
/// - `name`: 系統內建字型的 PostScript 名稱（例如：`"Bradley Hand"`）
/// - `ttf`: 外部 TTF 檔案名稱（例如：`"jf-openhuninn-2.1.ttf"`）
/// - `size`: 字型大小（例如：`42`）
struct FontDetail: Codable {
    
    let name: String?           // 系統內建字型的 PostScript 名稱（例如：`"Bradley Hand"`）
    let ttf: String?            // 外部 TTF 檔案名稱（例如：`"jf-openhuninn-2.1.ttf"`）
    let size: CGFloat?          // 字型大小（例如：`42`）
}
