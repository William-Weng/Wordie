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
    
    let image: Image
    @Binding var isAutoReading: Bool
    
    var onTap: (() -> Void)?
    
    var body: some View {
        
        Button {
            onTap?()
        } label: {
            Circle()
                .fill(!isAutoReading ? .orange : .red)
                .frame(width: 72, height: 72)
                .overlay(
                    image
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }
    
    /// 初始化WordPlayButton
    /// - Parameters:
    ///   - image: 外部傳入的圖示
    ///   - isAutoReading: 翻頁自動跟讀單字
    init(image: Image, isAutoReading: Binding<Bool>) {
        self.image = image
        _isAutoReading = isAutoReading
    }
}

// MARK: - 公開API (Modifier Style)
extension WordPlayButton {
    
    /// 按鈕點擊時要執行的動作
    func onTap(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onTap = action
        return copy
    }
}
