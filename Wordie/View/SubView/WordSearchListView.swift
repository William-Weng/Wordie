//
//  WordSearchListView.swift
//  Wordie
//
//  Created by William on 2026/7/22.
//

import SwiftUI

struct WordSearchListView: View {
    
    private let configure: Configure
    
    @Binding private var viewModel: WordListViewModel
    
    @State private var searchText = ""
    @State private var activeSheet: WordSheet?
    
    var body: some View {
        ZStack {
            
            backgroundView
            
            List(viewModel.words, id: \.id) { word in
                
                itemViewCard(word)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeSheet = .edit(word)
                    }
                    .padding(.horizontal, 8)
            }
            .navigationTitle(viewModel.api.tableName)
            .searchable(text: $searchText, placement: .toolbar, prompt: "單字搜尋")
            .listStyle(.plain)
            .onChange(of: searchText) { _, newValue in
                
                let keyword = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if keyword.isEmpty {
                    viewModel.reloadWords()
                } else {
                    viewModel.selectWord(from: keyword)
                }
                
            }.sheet(item: $activeSheet) { sheet in
                AddWordView(sheet: sheet, viewModel: viewModel)
            }
        }
        .preferredColorScheme(.light)
    }

    /// 建立單字搜尋列表畫面
    ///
    /// - Parameters:
    ///   - configure: 畫面外觀設定
    ///   - viewModel: 單字資料來源與操作邏輯
    init(configure: Configure, viewModel: Binding<WordListViewModel>) {
        self.configure = configure
        _viewModel = viewModel
    }
}

// MARK: - 子視圖
private extension WordSearchListView {
    
    /// 畫面背景漸層
    var backgroundView: some View {
        
        LinearGradient(
            colors: configure.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 單字卡片背景
    var itemBackgroundView: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.white.opacity(0.35))
    }
    
    /// 單字卡片邊框
    var itemBorder: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(.black.opacity(0.22), lineWidth: 1)
    }
    
    /// 單一單字卡片
    func itemViewCard(_ word: WordCard) -> some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            VStack(alignment: .leading, spacing: 6) {
                
                if configure.isAscending {
                    wordItem(word)
                    if !word.reading.isEmpty { readingItem(word) }
                } else {
                    if !word.reading.isEmpty { readingItem(word) }
                    wordItem(word)
                }
            }
            
            Spacer(minLength: 8)
            chineseItem(word)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            itemBackgroundView
        }
        .overlay {
            itemBorder
        }
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
 
// MARK: - 文字元件
private extension WordSearchListView {
    
    /// 顯示主要單字
    func wordItem(_ word: WordCard) -> some View {
        
        Text(word.word)
            .font(FontResolver.shared.searchWord)
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .layoutPriority(1)
    }
    
    /// 顯示讀音
    func readingItem(_ word: WordCard) -> some View {
        
        Text(word.reading)
            .font(FontResolver.shared.searchReading)
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }
    
    /// 顯示中文意思
    func chineseItem(_ word: WordCard) -> some View {
        
        Text(word.chinese)
            .font(FontResolver.shared.searchChinese)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
    }
}
