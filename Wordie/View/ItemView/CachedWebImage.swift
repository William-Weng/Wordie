//
//  CachedWebImage.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI

/// 可快取遠端圖片的 SwiftUI 視圖元件
///
/// 此元件會根據指定的 `url` 載入圖片，成功後將圖片交由 `content` 建立顯示內容；若圖片尚未載入完成，則顯示 `placeholder` 視圖
struct CachedWebImage<Content: View, Placeholder: View>: View {
    
    let url: URL?                                   // 要載入的遠端圖片網址
    let content: (Image) -> Content                 // 圖片載入成功後，用來建立顯示內容的閉包
    let placeholder: () -> Placeholder              // 圖片尚未載入完成時顯示的預設內容
    
    @State private var loader = WWWebImageLoader()  // 負責下載與快取圖片資料的載入器
    
    var body: some View {
        
        Group {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loader.load(from: url)
        }
    }
}
