//
//  WordCardView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// Word 卡片視圖
///
/// 根據 `isFlipped` 決定顯示正面（英文 + 音標）或背面（中文翻譯）
struct WordCardView: View {
    
    let wordCard: WordCard          // 當前單字資料
    let isFlipped: Bool             // 是否顯示翻面狀態
    let isAscending: Bool           // 英文與音標的順序 (英日文顯示不同)
    
    var body: some View {
        background
            .overlay(face)                                                          // 疊加正面或背面內容
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))   // 讓整張卡片都可被點擊，不只文字區域
    }
}

// MARK: - 私有屬性
private extension WordCardView {
    
    /// 卡片背景
    ///
    /// 使用 RoundedRectangle 建立卡片外觀與陰影
    var background: some View {
        
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.white)
            .shadow(color: .orange.opacity(isFlipped ? 0.16 : 0.12), radius: isFlipped ? 16 : 10, x: 0, y: 8)
    }
    
    /// 卡片內容
    ///
    /// 正面顯示英文與音標，背面顯示中文翻譯
    var face: some View {
        
        Group {
            if !isFlipped {
                
                ZStack(alignment: .topLeading) {
                    
                    frontView
                        .padding(.horizontal, 20)
                    
                    categoryBadge(15)
                        .padding(.top, 12)
                        .padding(.leading, 12)
                    
                    levelBadge(wordCard.level)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                }
                
            } else {
                backView
                    .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - 私有屬性
private extension WordCardView {
    
    /// 正面：英文 + 音標
    var frontView: some View {
        
        ZStack(alignment: .bottomTrailing) {
            
            VStack(spacing: 8) {
                
                Spacer(minLength: 0)
                
                if isAscending {
                    Text(wordCard.word)
                        .font(FontResolver.shared.word)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text(wordCard.reading)
                        .font(FontResolver.shared.reading)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                } else {
                    
                    Text(wordCard.reading)
                        .font(FontResolver.shared.reading)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    Text(wordCard.word)
                        .font(FontResolver.shared.word)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// 顯示單字等級的標籤視圖
    ///
    /// 例如 `A1`、`B1` 這類等級文字，以圓角底色 badge 的方式呈現
    func levelBadge(_ level: any WordLevelDatabase) -> some View {
        
        Text(level.value)
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(level.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    /// 背面：中文翻譯
    var backView: some View {
        
        VStack(spacing: 18) {
            
            Spacer(minLength: 0)
            
            Text("中文翻譯")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.orange.opacity(0.9))
            
            Text(wordCard.chinese)
                .font(FontResolver.shared.chinese)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - 私有API
private extension WordCardView {
    
    /// 顯示單字詞性
    /// - Parameter rawValue: Int
    /// - Returns: View
    func categoryBadge(_ rawValue: Int) -> some View {
        
        let types = WordType.parseTypes(from: rawValue)
        
        return HStack(spacing: 4) {
            
            ForEach(types, id: \.binary) { type in
                
                Text(type.name)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(type.background)
                    )
            }
        }
    }
}
