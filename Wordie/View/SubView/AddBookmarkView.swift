//
//  AddBookmarkView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import SwiftUI

/// 單字新增 / 編輯表單畫面
struct AddBookmarkView: View {
    
    let sheet: BookmarkSheet
    
    @State var viewModel: BookmarkListViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var url = ""
    @State private var icon = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
        
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
    
    init(sheet: BookmarkSheet, viewModel: BookmarkListViewModel) {
        
        self.sheet = sheet
        self.viewModel = viewModel
        
        switch sheet {
        case .add:
            _title = State(initialValue: "")
            _url = State(initialValue: "")
            _icon = State(initialValue: "")
        case .edit(let bookmark):
            _title = State(initialValue: bookmark.title)
            _url = State(initialValue: bookmark.url)
            _icon = State(initialValue: bookmark.icon)
        }
    }
}

// MARK: - 畫面內容
private extension AddBookmarkView {
    
    /// 單字輸入表單
    ///
    /// 包含英文、音標與中文三個欄位
    var inputForm: some View {
        
        Form {
            Section("書籤資訊") {
                inputRow(systemName: "text.book.closed", placeholder: "Title", text: $title)
                inputRow(systemName: "link", placeholder: "URL", text: $url)
                inputRow(systemName: "person.crop.circle", placeholder: "ICON", text: $icon)
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
private extension AddBookmarkView {
    
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
                
                switch sheet {
                case .add: try? viewModel.addBookmark(title, url: url, icon: icon)
                case .edit(let bookmark): try? viewModel.updateBookmark(id: bookmark.id, title: title, url: url, icon: icon)
                }
                
                dismiss()
                
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
private extension AddBookmarkView {
    
    /// 判斷表單是否符合儲存條件
    ///
    /// 目前規則：
    /// - 英文不可為空
    /// - 中文不可為空
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
