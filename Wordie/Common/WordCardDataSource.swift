//
//  WordCardDataSource.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/16.
//

import Foundation

/// 將各語系文字統一轉成WordCard => 多專案共用
protocol WordCardDataSource {
    
    /// 轉成WordCard
    /// - Parameter diffculty: 單字難度 (使用者累加)
    /// - Returns: WordCard
    func toWordCard(diffculty: Int) -> WordCard
}
