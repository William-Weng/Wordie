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
                if keyword.isEmpty { viewModel.reloadWords(); return }
                viewModel.selectWord(from: keyword)
            }.sheet(item: $activeSheet) { sheet in
                AddWordView(sheet: sheet, viewModel: viewModel)
            }
        }
        .preferredColorScheme(.light)
    }
    
    /// 建立書籤列表主畫面
    ///
    /// - Parameters:
    ///   - api: 提供書籤資料查詢與異動功能的 API
    ///   - configure: 畫面外觀設定
    init(configure: Configure, viewModel: Binding<WordListViewModel>) {
        self.configure = configure
        _viewModel = viewModel
    }
}

private extension WordSearchListView {
    
    /// 畫面的背景漸層視圖
    var backgroundView: some View {
        
        LinearGradient(
            colors: configure.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    func itemViewCard(_ word: WordCard) -> some View {
        
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                if configure.isAscending {
                    Text(word.word)
                        .font(FontResolver.shared.searchWord)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .layoutPriority(1)

                    if !word.reading.isEmpty {
                        Text(word.reading)
                            .font(FontResolver.shared.searchReading)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                } else {
                    if !word.reading.isEmpty {
                        Text(word.reading)
                            .font(FontResolver.shared.searchReading)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Text(word.word)
                        .font(FontResolver.shared.searchWord)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .layoutPriority(1)
                }
            }

            Spacer(minLength: 8)

            Text(word.chinese)
                .font(FontResolver.shared.searchChinese)
                .foregroundStyle(.primary.opacity(0.8))
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.35))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.black.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
    
    func wordItem(_ word: WordCard) -> some View {
        
        Text(word.word)
            .font(FontResolver.shared.searchWord)
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .layoutPriority(1)
    }
    
    func readingItem(_ word: WordCard) -> some View {
        
        Text(word.reading)
            .font(FontResolver.shared.searchReading)
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }
    
    func chineseItem(_ word: WordCard) -> some View {
        
        Text(word.chinese)
            .font(FontResolver.shared.searchChinese)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
    }
}
