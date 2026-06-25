//
//  WebImageLoader.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI
import WWWebImage

/// 負責下載並提供圖片資料的載入器 (此型別會根據指定網址下載圖片，並將結果更新到可供 SwiftUI 觀察的狀態)
@MainActor @Observable
final class WebImageLoader {
    
    var image: UIImage?     // 目前已載入完成的圖片
    var isLoading = false   // 表示目前是否正在進行圖片載入
    
    /// 從指定網址下載圖片並更新狀態
    ///
    /// 此方法會在開始下載時將 `isLoading` 設為 `true`，結束時自動恢復為 `false`。若下載成功，會更新 `uiImage`；若失敗，則將 `uiImage` 設為 `nil`
    ///
    /// - Parameter url: 要下載的圖片網址；若為 `nil` 則不進行載入
    func load(from url: URL?) async {
        
        guard let url else { image = nil; return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let imageView = UIImageView()
            try await imageView.ww.download(urlString: url.absoluteString)
            self.image = imageView.image
        } catch {
            self.image = nil
        }
    }
}
