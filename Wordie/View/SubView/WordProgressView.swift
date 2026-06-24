//
//  WordProgressView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// 顯示目前單字輪次與進度條的元件
struct WordProgressView: View {
    
    let totalCount: Int
    let range: ClosedRange<Double>      // Slider數字範圍

    @Binding var currentIndex: Int

    var body: some View {
        
        VStack(spacing: 8) {
            Text(progressDescription)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.gray)
            Slider(value: progressValue, in: range)
                .frame(height: 8)
                .padding(.horizontal, 28)
        }
        .padding(.top, 8)
    }
    
    /// [初始化](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/swiftui-滑動選值的-slider-b2d8c0a9966e)
    /// - Parameters:
    ///   - totalCount: 單字總數
    ///   - currentIndex: 目前索引
    init(totalCount: Int, currentIndex: Binding<Int>) {
        
        self.totalCount = totalCount
        _currentIndex = currentIndex
        self.range = 0...max(Double(totalCount - 1), 0.0)
    }
}

// MARK: - 私有屬性
private extension WordProgressView {
        
    /// [顯示目前是第幾輪 / 總共幾輪](https://levelup.gitconnected.com/swiftui-custom-slider-305aa7cf9e01)
    var progressDescription: String {
        guard totalCount > 0 else { return "Round 0 / 0" }
        return "Round \((currentIndex % totalCount) + 1) / \(totalCount)"
    }
    
    /// [頁數進度值，範圍介於 0 ~ (單字總數 - 1)](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-frame-或-grid-gridrow-解決-swiftui-slider-排列不整齊的問題-9722d4c68f7c)
    var progressValue: Binding<Double> {
        
        Binding(
            get: {
                Double(currentIndex)
            },
            set: { newValue in
                guard totalCount > 0 else { return }
                currentIndex = min(max(Int(newValue.rounded()), 0), totalCount - 1)
            }
        )
    }
}

