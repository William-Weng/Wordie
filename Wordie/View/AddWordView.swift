//
//  AddWordView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

struct AddWordView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WordListViewModel
    
    @State private var english = ""
    @State private var phonetic = ""
    @State private var chinese = ""
    
    var body: some View {
        
        NavigationStack {
            inputForm
                .navigationTitle("新增單字")
                .toolbar {
                    cancelItem
                    confirmItem
                }
        }
    }
}

// MARK: - 畫面內容
private extension AddWordView {
    
    /// 單字新增表單，包含英文、音標與中文欄位
    var inputForm: some View {
        
        Form {
            Section("單字資訊") {
                inputRow(systemName: "textformat", placeholder: "English", text: $english)
                inputRow(systemName: "quote.opening", placeholder: "Phonetic", text: $phonetic)
                inputRow(systemName: "translate", placeholder: "Chinese", text: $chinese)
            }
        }
    }
}

// MARK: - 畫面內容
private extension AddWordView {
        
    /// 建立帶有圖示的輸入列
    /// - Parameters:
    ///   - systemName: SF Symbol 圖示名稱。
    ///   - placeholder: 欄位提示文字。
    ///   - text: 綁定的輸入內容。
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
    
    /// 儲存按鈕，將輸入內容寫入資料庫後關閉畫面。
    @ToolbarContentBuilder
    var confirmItem: some ToolbarContent {
        
        ToolbarItem(placement: .confirmationAction) {
            Button("儲存") {
                viewModel.addWord(.init(english: english, phonetic: phonetic, chinese: chinese))
                dismiss()
            }
            .disabled(!isFormValid)
        }
    }
    
    /// 取消按鈕，直接關閉新增畫面
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
    
    /// 檢查表單是否可儲存
    var isFormValid: Bool {
        !english.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !chinese.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
