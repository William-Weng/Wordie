//
//  AddWordView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// 單字新增 / 編輯表單畫面
struct AddWordView: View {
    
    let sheet: WordSheet                                // 目前表單顯示的模式與內容來源
    
    @State var viewModel: WordListViewModel             // 單字列表的 ViewModel，負責新增與更新資料
    
    @Environment(\.dismiss) private var dismiss         // 關閉目前 sheet 畫面的環境方法
    
    @State private var word = ""                        // 英文單字輸入欄位
    @State private var reading = ""                     // 音標輸入欄位
    @State private var chinese = ""                     // 中文解釋輸入欄位
    
    @State private var showAlert = false                // 是否顯示錯誤提示視窗
    @State private var alertMessage = ""                // 錯誤提示內容
    
    var body: some View {
        
        NavigationStack {
            inputForm
                .navigationTitle(sheet.title)
                .toolbar {
                    cancelItem
                    confirmItem
                }
        }
    }
    
    /// 建立新增 / 編輯單字畫面
    ///
    /// 會根據 `sheet` 狀態設定表單初始值：
    /// - 新增模式：欄位清空
    /// - 編輯模式：帶入既有單字內容
    ///
    /// - Parameters:
    ///   - sheet: 目前 sheet 的狀態
    ///   - viewModel: 提供新增與更新功能的 ViewModel
    init(sheet: WordSheet, viewModel: WordListViewModel) {
        
        self.sheet = sheet
        self.viewModel = viewModel
        
        switch sheet {
        case .add:
            _word = State(initialValue: "")
            _reading = State(initialValue: "")
            _chinese = State(initialValue: "")
            
        case .edit(let wordCard):
            _word = State(initialValue: wordCard.word)
            _reading = State(initialValue: wordCard.reading)
            _chinese = State(initialValue: wordCard.chinese)
        case .intellisense(_):
            break
        }
    }
}

// MARK: - 畫面內容
private extension AddWordView {
    
    /// 單字輸入表單
    ///
    /// 包含英文、音標與中文三個欄位
    var inputForm: some View {
        
        Form {
            Section("單字資訊") {
                inputRow(systemName: "textformat", placeholder: "Word", text: $word)
                inputRow(systemName: "quote.opening", placeholder: "Reading", text: $reading)
                inputRow(systemName: "translate", placeholder: "Chinese", text: $chinese)
            }
        }
    }
    
    /// 建立帶有圖示的單列輸入欄位
    ///
    /// - Parameters:
    ///   - systemName: 左側顯示的 SF Symbol 名稱
    ///   - placeholder: 輸入欄位的提示文字
    ///   - text: 對應的輸入內容綁定值
    ///
    /// - Returns: 一個含圖示與文字輸入框的橫向列
    func inputRow(systemName: String, placeholder: String, text: Binding<String>) -> some View {
        
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .foregroundStyle(.secondary)
                .frame(width: 22)
            
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }
}

// MARK: - 工具列按鈕
private extension AddWordView {
    
    /// 右上角確認按鈕
    ///
    /// - 新增模式：建立新單字
    /// - 編輯模式：更新既有單字
    ///
    /// 如果操作失敗，會顯示錯誤提示
    @ToolbarContentBuilder
    var confirmItem: some ToolbarContent {
        
        ToolbarItem(placement: .confirmationAction) {
            
            Button {
                
                let wordUI = WordUI(word: word, reading: reading, category: 0, chinese: chinese)
                
                do {
                    switch sheet {
                    case .add: try viewModel.addWord(wordUI)
                    case .edit(let source): try viewModel.updateWord(id: source.id, wordUI: wordUI)
                    case .intellisense(_): break
                    }
                    
                    dismiss()
                } catch {
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            } label: {
                Image(systemName: sheet.buttonIcon)
            }
            .disabled(!isFormValid)
            .alert("錯誤", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
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

// MARK: - 驗證
private extension AddWordView {
    
    /// 判斷表單是否符合儲存條件
    ///
    /// 目前規則：
    /// - 英文不可為空
    /// - 中文不可為空
    var isFormValid: Bool {
        !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !chinese.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
