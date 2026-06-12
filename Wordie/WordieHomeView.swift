//
//  WordieHomeView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import SwiftUI

struct WordieHomeView: View {
    
    @StateObject private var viewModel = WordListViewModel()
    @State private var activeSheet: WordSheet?
    
    var body: some View {
        NavigationStack {
            WordieContentView(words: viewModel.words)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    addItem
                    editItem
                }
                .sheet(item: $activeSheet) { sheet in
                    AddWordView(sheet: sheet, viewModel: viewModel)
                }
        }
        .task {
            viewModel.loadWords()
        }
    }
}

// MARK: - Toolbar
private extension WordieHomeView {
    
    @ToolbarContentBuilder
    var addItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                activeSheet = .add
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    @ToolbarContentBuilder
    var editItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                guard let firstWord = viewModel.words.first else { return }
                activeSheet = .edit(firstWord)
            } label: {
                Image(systemName: "pencil")
            }
        }
    }
}
