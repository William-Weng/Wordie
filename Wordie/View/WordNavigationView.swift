//
//  WordNavigationView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// 單字頁面的上一張 / 下一張導覽按鈕
///
/// 圖示與動作都由外部傳入，方便重用與更換樣式
struct WordNavigationView: View {
    
    let canGoPrevious: Bool             // 是否可以切到上一張
    let canGoNext: Bool                 // 是否可以切到下一張
    let previousImage: Image            // 上一張按鈕圖示
    let nextImage: Image                // 下一張按鈕圖示
    let previousAction: () -> Void      // 按下上一張時執行的動作
    let nextAction: () -> Void          // 按下下一張時執行的動作
    
    var body: some View {
        
        HStack(spacing: 24) {
            navigationButtonView(       // 左側導覽按鈕
                canGo: canGoPrevious,
                image: previousImage,
                action: previousAction
            )
            navigationButtonView(       // 右側導覽按鈕
                canGo: canGoNext,
                image: nextImage,
                action: nextAction
            )
        }
        .padding(.top, 10)
    }
}

// MARK: - 小工具
private extension WordNavigationView {
    
    /// 建立單一圓形導覽按鈕 => 可用時是深灰，不可用時是淺灰
    /// - Parameters:
    ///   - canGo: 是否可互動
    ///   - image: 按鈕圖示
    ///   - action: 點擊動作
    func navigationButtonView(canGo: Bool, image: Image, action: @escaping () -> Void) -> some View {
        
        Button(action: action) {
            Circle()
                .fill(canGo ? Color.gray.opacity(0.8) : Color.gray.opacity(0.35))
                .frame(width: 62, height: 62)
                .overlay(
                    image
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)    // 使用 plain 避免系統按鈕樣式干擾外觀
        .disabled(!canGo)       // 不可用時禁用點擊

    }
}
