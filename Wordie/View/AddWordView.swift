//
//  AddWordView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

struct AddWordView: View {
    
    let sheet: WordSheet
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WordListViewModel
    
    @State private var english = ""
    @State private var phonetic = ""
    @State private var chinese = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(sheet: WordSheet, viewModel: WordListViewModel) {
        
        self.sheet = sheet
        self.viewModel = viewModel
        
        switch sheet {
        case .add:
            _english = State(initialValue: "")
            _phonetic = State(initialValue: "")
            _chinese = State(initialValue: "")
            
        case .edit(let word):
            _english = State(initialValue: word.english)
            _phonetic = State(initialValue: word.phonetic)
            _chinese = State(initialValue: word.chinese)
        }
    }
    
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
}

// MARK: - 畫面內容
private extension AddWordView {
    
    var inputForm: some View {
        
        Form {
            Section("單字資訊") {
                inputRow(systemName: "textformat", placeholder: "English", text: $english)
                inputRow(systemName: "quote.opening", placeholder: "Phonetic", text: $phonetic)
                inputRow(systemName: "translate", placeholder: "Chinese", text: $chinese)
            }
        }
    }
    
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
    
    @ToolbarContentBuilder
    var confirmItem: some ToolbarContent {
        
        ToolbarItem(placement: .confirmationAction) {
            
            Button {
                let wordUI = WordUI(english: english, phonetic: phonetic, chinese: chinese)
                
                do {
                    switch sheet {
                    case .add: try viewModel.addWord(wordUI)
                    case .edit(let word):
                        let updatedWord = Word(id: word.id, english: wordUI.english, phonetic: wordUI.phonetic, chinese: wordUI.chinese)
                        try viewModel.updateWord(updatedWord)
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
    
    var isFormValid: Bool {
        !english.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !chinese.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
