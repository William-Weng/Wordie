//
//  WordieContentView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// Wordie 主畫面
///
/// 負責顯示單字卡片、翻牌、左右切換與發音按鈕
struct WordieContentView: View {
    
    let words: [WordCard]                           // 單字資料來源
    let configure: Configure                        // 一般初始化設定

    @Binding var currentIndex: Int                  // 目前顯示綁定的單字索引
    
    @State private var dragOffset: CGFloat = 0      // 拖曳偏移量 => 用來做滑動切頁動畫
    @State private var isAnimatingPage = false      // 是否正在執行翻頁動畫
    @State private var isFlipped = false            // 目前卡片是否翻面
    @State private var isPresentingAddWord = false
    
    var body: some View {
        
        ZStack {
            background
            
            VStack(spacing: 20) {
                
                titleView
                
                WordieMascotView(image: Image(systemName: configure.icon))
                
                if words.isEmpty {
                    emptyStateView
                        .frame(height: 320)
                        .padding(.horizontal, 28)

                } else {
                    cardStack
                        .frame(height: 320)
                        .padding(.horizontal, 28)
                }
                
                WordProgressView(currentIndex: currentIndex, totalCount: words.count)
                
                functionKeyView
                
                WordPlayButton(image: Image(systemName: "play.fill")) {
                    guard words.indices.contains(currentIndex) else { return }
                    playWord(words[currentIndex].word)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.bottom, 18)
        }.onChange(of: words.count) {
            clampCurrentIndex()
        }
    }
}

// MARK: - 私有View
private extension WordieContentView {
    
    /// 顯示功能按鈕區 => 包含上一張 / 下一張導覽按鈕，以及翻牌按鈕
    var functionKeyView: some View {
        
        HStack(spacing: 14) {
            
            WordNavigationView(
                canGoPrevious: true,
                canGoNext: true,
                previousImage: Image(systemName: "chevron.left"),
                nextImage: Image(systemName: "chevron.right"),
                previousAction: previousWord,
                nextAction: nextWord
            )
            
            Button(action: flipCard) {
                Text(isFlipped ? "看正面" : "翻牌")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
    }
    
    /// 背景漸層
    var background: some View {
        
        LinearGradient(
            colors: configure.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 標題文字
    var titleView: some View {
        
        Text(configure.title)
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundStyle(.orange)
            .padding(.top, 24)
    }
    
    /// 空狀態內容
    var emptyStateView: some View {
        
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("目前沒有單字")
                .font(.headline)

            Text("先新增一些 Wordie 單字，再開始學習吧。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.12))
        )
    }
    
    /// 三層卡片堆疊
    var cardStack: some View {
        
        ZStack {
            
            /// 最後方卡片
            if let farBackWord {
                WordCardView(wordCard: farBackWord, isFlipped: false, isAscending: configure.isAscending)
                    .offset(x: farBackOffsetX, y: farBackOffsetY)
                    .scaleEffect(farBackScale)
                    .rotationEffect(.degrees(farBackRotation))
                    .opacity(farBackOpacity)
                    .zIndex(0)
                    .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.9), value: currentIndex)
                    .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.9), value: dragOffset)
            }
            
            /// 中間卡片
            if let backWord {
                WordCardView(wordCard: backWord, isFlipped: false, isAscending: configure.isAscending)
                    .offset(x: backOffsetX, y: backOffsetY)
                    .scaleEffect(backScale)
                    .rotationEffect(.degrees(backRotation))
                    .opacity(backOpacity)
                    .zIndex(1)
                    .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.9), value: currentIndex)
                    .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.9), value: dragOffset)
            }
            
            /// 前景卡片
            if let currentWord {
                WordCardView(wordCard: currentWord, isFlipped: isFlipped, isAscending: configure.isAscending)
                    .offset(x: dragOffset, y: frontLift)
                    .scaleEffect(frontScale)
                    .rotationEffect(.degrees(frontRotation))
                    .shadow(color: .black.opacity(frontShadowOpacity), radius: 18, x: frontShadowX, y: 8)
                    .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .highPriorityGesture(deckDragGesture)
                    .onTapGesture { flipCard() }
                    .zIndex(2)
            }
        }
    }
}

// MARK: - 私有拖曳手勢
private extension WordieContentView {
    
    /// 拖曳手勢 => 左滑切下一張，右滑切上一張
    var deckDragGesture: some Gesture {
        
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { handleDeckDragChanged($0) }
            .onEnded { try? handleDeckDragEnded($0) }
    }
}

// MARK: - 私有屬性
private extension WordieContentView {
    
    /// 目前正在顯示的單字
    ///
    /// 使用 `currentIndex` 搭配 `[safe:]` 取值，避免索引超出範圍時發生 crash
    var currentWord: WordCard? {
        words[safe: currentIndex]
    }
    
    /// 前一層預覽卡片要顯示的單字
    ///
    /// 依照拖曳方向決定要取上一筆或下一筆，讓卡片堆疊在滑動時能自然更新，同樣使用 `[safe:]` 保護索引，避免資料不足時越界
    var backWord: WordCard? {
        words[safe: loopIndex(currentIndex + (dragOffset < 0 ? -1 : 1))]
    }
    
    /// 最後一層預覽卡片要顯示的單字
    ///
    /// 依照拖曳方向再往外推一筆，作為三層卡片堆疊中的最底層預覽，透過 `[safe:]` 讓這層卡片也能在資料變動時維持安全
    var farBackWord: WordCard? {
        words[safe: loopIndex(currentIndex + (dragOffset < 0 ? -2 : 2))]
    }
}

// MARK: - 私有屬性
private extension WordieContentView {
            
    /// 上一張索引 => 會依照目前索引往前一筆，並支援循環
    var previousIndex: Int { loopIndex(currentIndex - 1) }
    
    /// 下一張索引 => 會依照目前索引往後一筆，並支援循環
    var nextIndex: Int { loopIndex(currentIndex + 1) }
    
    /// 拖曳進度值，範圍為 0 到 1 => 用來控制後方卡片的位移、縮放與旋轉動畫
    var dragProgress: CGFloat {
        let width = max(UIScreen.main.bounds.width, 1)
        return min(max(abs(dragOffset) / width, 0), 1)
    }
    
    /// 是否正在往下一張滑動
    var swipingNext: Bool { dragOffset < 0 }
    
    /// 前景卡片的浮動高度
    var frontLift: CGFloat { -min(abs(dragOffset) * 0.035, 10) }
    
    /// 前景卡片的縮放比例
    var frontScale: CGFloat { 1 - min(abs(dragOffset) / 2400, 0.02) }
    
    /// 前景卡片的旋轉角度
    var frontRotation: Double { Double(dragOffset / 42) }
    
    /// 前景卡片陰影透明度
    var frontShadowOpacity: Double { 0.08 + Double(min(abs(dragOffset) / 700, 0.08)) }
    
    /// 前景卡片陰影水平偏移
    var frontShadowX: CGFloat { dragOffset / 20 }
    
    /// 中間後方卡片的 X 偏移
    var backOffsetX: CGFloat {
        let pull: CGFloat = 14
        return swipingNext ? 10 - pull * dragProgress : 10 + pull * dragProgress
    }
    
    /// 中間後方卡片的 Y 偏移
    var backOffsetY: CGFloat { 14 - (12 * dragProgress) }
    
    /// 中間後方卡片的縮放比例
    var backScale: CGFloat { 0.94 + 0.045 * dragProgress }
    
    /// 中間後方卡片的旋轉角度
    var backRotation: Double { swipingNext ? 0.55 - Double(0.55 * dragProgress) : -0.55 + Double(0.55 * dragProgress) }
    
    /// 中間後方卡片的透明度
    var backOpacity: Double { 0.92 + 0.06 * Double(dragProgress) }
    
    /// 最後方卡片的 X 偏移
    var farBackOffsetX: CGFloat { swipingNext ? 20 - 6 * dragProgress : 20 + 6 * dragProgress }
    
    /// 最後方卡片的 Y 偏移
    var farBackOffsetY: CGFloat { 28 - 6 * dragProgress }
    
    /// 最後方卡片的縮放比例
    var farBackScale: CGFloat { 0.88 + 0.02 * dragProgress }
    
    /// 最後方卡片的旋轉角度
    var farBackRotation: Double { swipingNext ? 0.28 - Double(0.18 * dragProgress) : -0.28 + Double(0.18 * dragProgress) }
    
    /// 最後方卡片的透明度
    var farBackOpacity: Double { 0.68 + 0.10 * Double(dragProgress) }
}

// MARK: - 小工具
private extension WordieContentView {
    
    /// 卡片滑出動畫
    /// - Parameters:
    ///   - direction: -1 代表往左，1 代表往右
    ///   - update: 動畫結束後要執行的索引更新
    func animateCardAway(direction: CGFloat, update: @escaping () -> Void) throws {
        
        isAnimatingPage = true
        
        let width = UIScreen.main.bounds.width
        let target = direction * width * 0.95
        
        withAnimation(.easeOut(duration: 0.13)) { dragOffset = target }
        
        Task { @MainActor in
            
            try await Task.sleep(for: .milliseconds(110))
            
            update()
            isFlipped = false
            dragOffset = -direction * 12
            
            withAnimation(.easeOut(duration: 0.09)) { dragOffset = 0 }
            
            try await Task.sleep(for: .milliseconds(100))
            isAnimatingPage = false
        }
    }
    
    /// 將索引限制在單字陣列範圍內，並支援循環
    func loopIndex(_ index: Int) -> Int {
        
        guard !words.isEmpty else { return 0 }
        
        let remainder = index % words.count
        return remainder >= 0 ? remainder : remainder + words.count
    }
    
    /// 切到上一張
    func previousWord() {
        guard !isFlipped else { return }
        try? animateCardAway(direction: 1) { currentIndex = previousIndex }
    }
    
    /// 切到下一張
    func nextWord() {
        guard !isFlipped else { return }
        try? animateCardAway(direction: -1) { currentIndex = nextIndex }
    }
    
    /// 翻牌
    func flipCard() {
        guard !isAnimatingPage else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { isFlipped.toggle() }
    }
    
    /// 播放當前單字發音
    func playWord(_ text: String) {
        SpeechService.shared.speak(text, language: configure.language)
    }
    
    /// 將目前索引限制在有效範圍內
    ///
    /// 當單字陣列是空的時，直接把 `currentIndex` 設為 0，如果索引超出陣列範圍，則修正到最後一筆或第一筆，避免發生越界
    func clampCurrentIndex() {
        
        guard !words.isEmpty else { currentIndex = 0; return }
        
        if currentIndex >= words.count { currentIndex = words.count - 1 }
        if currentIndex < 0 { currentIndex = 0 }
    }
}

// MARK: - DragGesture
private extension WordieContentView {
    
    /// 拖曳中：更新卡片偏移量
    func handleDeckDragChanged(_ value: DragGesture.Value) {
        guard !isAnimatingPage, !isFlipped else { return }
        dragOffset = value.translation.width
    }
    
    /// 拖曳結束：判斷是否要切換上一張或下一張
    func handleDeckDragEnded(_ value: DragGesture.Value) throws {
        
        guard !isAnimatingPage, !isFlipped else { return }
        
        let threshold: CGFloat = 90
        let predicted = value.predictedEndTranslation.width
        
        if predicted < -threshold {
            try animateCardAway(direction: -1) { currentIndex = nextIndex }
        } else if predicted > threshold {
            try animateCardAway(direction: 1) { currentIndex = previousIndex }
        } else {
            withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.9)) { dragOffset = 0 }
        }
    }
}
