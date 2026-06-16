//
//  WordProgressView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// 顯示目前單字輪次與進度條的元件
struct WordProgressView: View {
    
    let currentIndex: Int   // 目前索引
    let totalCount: Int     // 單字總數
    
    var body: some View {
        
        VStack(spacing: 8) {
            Text(progressDescription)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.gray)
            progressView(progress)
                .frame(height: 8)
                .padding(.horizontal, 28)
        }
        .padding(.top, 8)
    }
}

// MARK: - 私有屬性
private extension WordProgressView {
    
    /// 進度值，範圍介於 0 到 1
    /// 用來計算進度條填滿比例。
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double((currentIndex % totalCount) + 1) / Double(totalCount)
    }
    
    /// 顯示目前是第幾輪 / 總共幾輪
    var progressDescription: String {
        guard totalCount > 0 else { return "Round 0 / 0" }
        return "Round \((currentIndex % totalCount) + 1) / \(totalCount)"
    }
}

// MARK: - 小工具
private extension WordProgressView {
    
    /// 進度條視圖
    /// - Parameter progress: 0 到 1 的進度比例
    func progressView(_ progress: Double) -> some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.18))
                Capsule()
                    .fill(Color.orange)
                    .frame(width: geometry.size.width * progress)
            }
        }
    }
}
