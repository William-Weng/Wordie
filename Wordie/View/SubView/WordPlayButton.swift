//
//  WordPlayButton.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// 播放單字發音的按鈕
///
/// 使用橘色圓形背景與播放圖示，點擊後執行外部傳入的 action
struct WordPlayButton: View {
    
    let image: Image                                            // 外部傳入的圖示
    let action: () -> Void                                      // 按鈕點擊時要執行的動作
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(.orange)                                  // 按鈕背景色
                .frame(width: 72, height: 72)                   // 固定圓形尺寸
                .overlay(
                    image                                       // 在圓形中置中顯示播放圖示
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)                                    // 使用 plain 樣式，避免系統自動加上多餘外觀
        .padding(.top, 8)                                       // 與上方其他元件保持一點距離
    }
}
