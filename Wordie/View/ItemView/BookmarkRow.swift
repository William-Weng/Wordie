//
//  BookmarkRow.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI

/// 書籤列表中的單筆列項目視圖
///
/// 此視圖負責顯示書籤資訊，並提供：
/// - 點擊列項目
/// - 切換最愛狀態
struct BookmarkRow: View {
    
    var bookmark: Bookmark      // 要顯示的書籤資料
    
    let onItemTap: () -> Void   // 點擊整列項目時執行的動作
    
    /// 點擊最愛按鈕時執行的動作
    ///
    /// - Parameter bookmark: 目前列項目的書籤資料
    let onFavoriteTap: (Bookmark) -> Void
        
    var body: some View {
        
        HStack(spacing: 20) {
            
            Button {
                onFavoriteTap(bookmark)
            } label: {
                favoriteIcon
            }
            .buttonStyle(.plain)

            Button(action: onItemTap) {
                HStack(spacing: 20) {
                    coverImage
                    titleView
                    rightIcon
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .contentShape(Rectangle())
    }
}

// MARK: - 小工具
private extension BookmarkRow {
        
    /// 書籤圖示的封面圖片視圖
    ///
    /// 會優先顯示遠端圖片，下載期間則顯示預設的載入中佔位畫面
    var coverImage: some View {
        
        let width: CGFloat = 56
        
        return CachedWebImage(url: URL(string: bookmark.icon)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.45))
                ProgressView()
            }
        }
        .frame(width: width, height: width)
        .clipShape(RoundedRectangle(cornerRadius: width * 0.5))
    }
    
    /// 書籤最愛狀態的圖示視圖
    ///
    /// 會依 `bookmark.isFavorite` 顯示已收藏或未收藏的愛心圖示
    var favoriteIcon: some View {
        
        Image(systemName: bookmark.isFavorite ? "heart.fill" : "heart")
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(bookmark.isFavorite ? .red : .gray)
            .frame(width: 30)
    }
    
    /// 列項目右側的導覽箭頭圖示
    var rightIcon: some View {
        
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.gray)
    }
    
    /// 顯示書籤標題的文字視圖
    var titleView: some View {
        
        Text(bookmark.title)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
