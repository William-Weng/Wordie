//
//  IntelliSenseWordView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/16.
//

#if canImport(WWIntelligentAgent)
import SwiftUI
import WWIntelligentAgent

/// 使用iOS本地AI解說單字
@available(iOS 26.0, *)
struct IntelliSenseWordView: View {
    
    let sheet: WordSheet
    let instructions: String
    
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: WordListViewModel

    @State private var word: String             // 目前要讓 AI 解說的單字
    @State private var explain: String          // AI 回傳的解說內容
    @State private var isLoading = true         // 是否正在等待 AI 回應
    
    private let agent = WWIntelligentAgent()    // AI 對話代理
    
    init(sheet: WordSheet, viewModel: WordListViewModel, instructions: String) {
        
        self.sheet = sheet
        self.viewModel = viewModel
        self.instructions = instructions
        
        switch sheet {
        case .add, .edit:
            _word = State(initialValue: "")
            _explain = State(initialValue: "")
        case .intellisense(let wordCard):
            _word = State(initialValue: wordCard.word)
            _explain = State(initialValue: "")
        }
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                if isLoading {
                    progressView
                } else {
                    explainView
                }
            }
            .padding()
            .navigationTitle(sheet.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelItem
            }
        }.task {
            
            defer { isLoading = false }
            
            let prompt = "請解說\(word)"
            agent.configure(with: instructions)
            
            do {
                let result = try await agent.chat(to: prompt)
                self.explain = result
            } catch {
                self.explain = error.localizedDescription
            }
            
        }
    }
}

// MARK: - AI顯示
@available(iOS 26.0, *)
private extension IntelliSenseWordView {
    
    /// AI 載入中時顯示的畫面
    var progressView: some View {
        ProgressView("AI 思考中…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// AI 完成後顯示的解說內容
    var explainView: some View {
        ScrollView {
            Text(explain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding()
        }
    }
}

// MARK: - 工具列按鈕
@available(iOS 26.0, *)
private extension IntelliSenseWordView {
    
    /// 左上角取消按鈕，關閉目前表單畫面
    @ToolbarContentBuilder
    var cancelItem: some ToolbarContent {
        
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Label("取消", systemImage: "xmark")
                    .labelStyle(.iconOnly)
            }
        }
    }
}

#endif
