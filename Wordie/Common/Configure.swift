//
//  Configure.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/16.
//
//  UIFileSharingEnabled = YES（啟用檔案共享）
//  LSSupportsOpeningDocumentsInPlace = YES（允許直接開啟與編輯檔案）
//  UISupportsDocumentBrowser = YES（讓 App 的 Documents 目錄可在 Files App 的「On My iPhone」中顯示）

import SwiftUI

struct Configure {
    
    let title: String           // 主題文字
    let icon: String            // 主題圖示
    let language: String        // 發音語系
    let colors: [Color]         // 背景顏色
    let isAscending: Bool       // 字義順序
    let instructions: String    // 設定AI對話規則
}
