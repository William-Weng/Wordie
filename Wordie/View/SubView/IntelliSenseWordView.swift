//
//  IntelliSenseWordView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/16.
//

#if canImport(WWIntelligentAgent)
import SwiftUI
import WWIntelligentAgent
import WWMarkdownWebViewUI

/// 使用iOS本地AI解說單字
@available(iOS 26.0, *)
struct IntelliSenseWordView: View {
    
    static private let agent = WWIntelligentAgent()     // AI 對話代理
    
    let sheet: WordSheet
    let instructions: String
    
    private let speechService: SpeechService = .init()
    
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: WordListViewModel
    @State var manager = WWMarkdownWebViewUI.Manager()
    
    @State private var word: String                     // 目前要讓 AI 解說的單字
    @State private var markdown: String                 // AI 回傳的解說內容
    @State private var isLoading = true                 // 是否正在等待 AI 回應
    @State private var webHeight: CGFloat = 1           // WebView高度
    
    init(sheet: WordSheet, viewModel: WordListViewModel, instructions: String) {
        
        self.sheet = sheet
        self.viewModel = viewModel
        self.instructions = instructions
        
        switch sheet {
        case .add, .edit:
            _word = State(initialValue: "")
            _markdown = State(initialValue: "")
        case .intellisense(let wordCard):
            _word = State(initialValue: wordCard.word)
            _markdown = State(initialValue: "")
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
                readContentItem
                analyzeItem
            }
        }.task {
            await analyzeWord(word)
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
                WWMarkdownWebViewUI(markdown: markdown, height: $webHeight, textStyle: .constant(.dark), manager: manager)
                    .frame(height: webHeight)
                    .padding(20)
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
    
    /// 再由 AI 分析單字一次的按鈕
    @ToolbarContentBuilder
    var analyzeItem: some ToolbarContent {
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task { await analyzeWord(word) }
            } label: {
                Label("分析單字", systemImage: "brain.head.profile")
                    .labelStyle(.iconOnly)
            }
            .disabled(isLoading)
        }
    }
    
    /// 讀出 AI 分析完的內容
    @ToolbarContentBuilder
    var readContentItem: some ToolbarContent {
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task { try await speakTextContent() }
            } label: {
                Label("讀出分析內容", systemImage: "speaker.wave.3")
                    .labelStyle(.iconOnly)
            }
            .disabled(isLoading)
        }
    }
}

// MARK: - AI工具
@available(iOS 26.0, *)
private extension IntelliSenseWordView {
    
    /// 由AI分析單字
    /// - Parameter word: 要分析的單字
    func analyzeWord(_ word: String) async {
        
        defer { isLoading = false }
        
        let prompt = "這是使用者說的：請解說\(word)"
        Self.agent.configure(with: instructions, optionType: .bot)
        isLoading = true
        
        do {
            let result = try await Self.agent.chat(to: prompt)
            self.markdown = result
        } catch {
            self.markdown = error.localizedDescription
        }
    }
}

// MARK: - AI工具
@available(iOS 26.0, *)
private extension IntelliSenseWordView {
    
    /// 讀出分析的純文字內容
    func speakTextContent() async throws {
        
        let textContent = try await manager.getTextContent() ?? ""
        let content = textContent.replacingOccurrences(of: "\n", with: ". ")
        
        speechService.speak(content, language: "zh-TW")
    }
}

#endif
