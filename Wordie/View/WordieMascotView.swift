//
//  WordieMascotView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// Wordie 的吉祥物圖示元件
///
/// 由外部傳入 `Image`，方便之後替換成不同的 system icon 或 asset 圖片
struct WordieMascotView: View {
    
    let image: Image                    // 外部傳入的圖示 => 可以是 `Image(systemName:)`，也可以是資產圖 `Image("xxx")`
    
    var body: some View {
        image
            .renderingMode(.template)   // 使用 template 模式，讓圖片可以套用前景色
            .font(.system(size: 64))    // 設定圖示大小
            .foregroundStyle(.orange)   // 統一改成橘色，符合 Wordie 視覺風格

    }
}
