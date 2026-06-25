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

/// 使用 iOS 本地 AI 解說單字的畫面
///
/// 此視圖會根據指定單字產生 AI 解說內容，並提供：
/// - 顯示 AI 回傳的 Markdown 說明
/// - 重新分析單字
/// - 朗讀解說內容
@available(iOS 26.0, *)
struct IntelliSenseWordView: View {
    
    static private let agent = WWIntelligentAgent()         // AI 對話代理
    
    let sheet: WordSheet                                    // 目前畫面所對應的工作模式
    let instructions: String                                // 提供給 AI 的額外指示內容
    
    private let speechService: SpeechService = .init()      // 提供文字朗讀功能的服務
    
    @State var viewModel: WordListViewModel                 // 管理單字列表資料與操作邏輯的 ViewModel
    @State var manager = WWMarkdownWebViewUI.Manager()      // 管理 Markdown WebView 顯示狀態的物件
    @State private var word: String                         // 目前要讓 AI 解說的單字
    @State private var markdown: String                     // AI 回傳的 Markdown 解說內容
    @State private var isLoading = true                     // 是否正在等待 AI 回應
    @State private var webHeight: CGFloat = 1               // Markdown WebView 的內容高度
    
    @Environment(\.dismiss) private var dismiss             // 用來關閉目前畫面的 dismiss 動作
    
    /// 建立 AI 單字解說畫面
    ///
    /// 會依照 `sheet` 模式決定單字與初始內容：
    /// - 新增或編輯模式時，單字與解說內容皆為空
    /// - AI 解說模式時，會帶入要分析的單字
    ///
    /// - Parameters:
    ///   - sheet: 表示目前畫面用途的工作模式
    ///   - viewModel: 提供單字資料操作能力的 ViewModel
    ///   - instructions: 傳給 AI 的額外指示內容
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
        }
        .background(Color.githubDarkBackground)
        .task {
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
                WWMarkdownWebViewUI(markdown: markdown, height: $webHeight, manager: manager)
                    .frame(height: webHeight)
                    .padding(0)
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
        
        let prompt = "這是使用者說的：請解說'\(word)'這個單字"
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
