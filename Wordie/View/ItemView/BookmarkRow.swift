//
//  BookmarkRow.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI

struct BookmarkRow: View {
    
    @Binding var bookmark: Bookmark
    
    let onItemTap: () -> Void
    let onFavoriteTap: (Bookmark) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                bookmark.toggleFavorite()
                onFavoriteTap(bookmark)
            } label: {
                Image(systemName: bookmark.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(bookmark.isFavorite ? .red : .gray)
                    .frame(width: 30)
            }
            .buttonStyle(.plain)

            Button(action: onItemTap) {
                HStack(spacing: 20) {
                    coverImage
                    
                    Text(bookmark.title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
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

private extension BookmarkRow {
    
    var coverImage: some View {
        
        CachedWebImage(url: URL(string: bookmark.icon)) { image in
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
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}
