//
//  WordieHomeView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/11.
//

import SwiftUI

struct WordieHomeView: View {
    
    @StateObject private var viewModel = WordListViewModel()

    @State private var isPresentingAddWord = false
    
    var body: some View {
        NavigationStack {
            WordieContentView(words: viewModel.words)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresentingAddWord = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isPresentingAddWord) {
                    AddWordView(viewModel: viewModel)
                }

        }.onAppear {
            viewModel.loadWords()
        }
    }
}
