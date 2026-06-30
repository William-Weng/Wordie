# Wordie

![SwiftUI](https://img.shields.io/badge/SwiftUI-524520?logo=swift)
[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-17.0](https://img.shields.io/badge/iOS-17.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/Wordie)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

Wordie 是一款使用 SwiftUI 製作的英文單字學習 App，提供單字的新增、編輯、刪除與瀏覽功能，並透過 `SQLite` 在本機保存資料，適合作為 `SwiftUI` + `MVVM` + 本地資料庫練習專案，在 `iOS 26` 支援本地 [`AI`](https://www.apple.com/tw/apple-intelligence/) 功能。

![Wordie](https://github.com/user-attachments/assets/d6294971-f674-40b1-a6b1-1ba50b3dfb10) ![Kirie](https://github.com/user-attachments/assets/7e021171-5077-446b-8a63-71bb86f884d0)

## [畫面功能](https://peterpanswift.github.io/iphone-bezels/)

### [首頁](https://medium.com/在程式與旅行的路上/widget-extension-等到-ios-14-才姍姍來遲的-widget-小工具-7b269d9b2253)
- 顯示目前單字內容。
- 可切換單字瀏覽狀態。
- 提供新增、編輯與刪除入口。

### 新增 / 編輯單字
- 可輸入英文、音標與中文解釋。
- 編輯模式會自動帶入既有資料。
- 欄位驗證完成後才能送出。

## 使用技術

| 項目 | 說明 |
|------|------|
| UI Framework | `SwiftUI`  |
| 架構模式 | `MVVM` |
| 資料儲存 | `SQLite` |
| 語言 | `Swift` |

## 引用字型

| 名稱 | 說明 |
|------|------|
| [`PlaypenSans-VariableFont_wght.ttf`](https://fonts.google.com/specimen/Playpen+Sans) | 英文字型 |
| [`jf-openhuninn-2.1.ttf`](https://justfont.com/huninn/) | 中文字型 |
| [`KleeOne-Regular.ttf`](https://fonts.google.com/specimen/Klee+One) | 日文字型 |

- 如果要引用字型，記得在 `.documentsDirectory` 上加上 	`config.json` 設定檔	

![documentsDirectory](https://github.com/user-attachments/assets/55e66e0c-6262-4459-bd1b-deae5dd92d74)

## 執行方式

1. 使用 Xcode 開啟專案。
2. 選擇模擬器或實機。
3. 編譯並執行 App。
4. 進入首頁後，即可新增、編輯、刪除單字資料。

```swift
import SwiftUI

@main
struct WordieApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            WordieHomeView(
                api: .init(
                    filename: "Wordie.db",
                    tableName: "english",
                    type: EnglishWord.self
                ),
                configure: .init(
                    title: "Wordie",
                    icon: "bird.fill",
                    language: "en-US",
                    colors: [
                        Color(red: 0.98, green: 0.92, blue: 0.76),
                        Color(red: 0.95, green: 0.88, blue: 0.70)
                    ],
                    isAscending: true,
                    instructions: "你是位英文老師，會幫人解說英文單字"
                )
            )
        }
    }
}
```

## 核心流程

### 讀取資料
- `WordListViewModel` 呼叫 `API.shared.select()` 從資料庫讀取單字。
- 讀取完成後更新 `words`，讓畫面同步刷新。

### 新增資料
- 在 `AddWordView` 輸入資料後，呼叫 `viewModel.addWord(...)`。
- `WordListViewModel` 會再透過 `API.shared.insert(...)` 寫入資料庫。

### 編輯資料
- 編輯模式下會先帶入原有單字資料。
- 確認後呼叫 `updateWord(...)`，將內容更新至 SQLite。

### 刪除資料
- 從主畫面選擇刪除後，呼叫 `deleteWord(...)` 或刪除對應 id。
- 刪除成功後重新載入清單。

## 學習重點

這個專案很適合練習以下主題：

- SwiftUI 畫面切分與元件抽離。
- `@State`、`@Binding`、`@ObservedObject`、`@StateObject` 的使用方式。
- sheet、toolbar、alert、confirmationDialog 等 SwiftUI 常用 UI 流程。
- ViewModel 與資料存取層的分工。
- SQLite 基本 CRUD 操作。

## 後續可擴充方向

- 加入搜尋功能。
- 加入測驗模式或記憶卡模式。
- 支援匯出 / 匯入單字資料。
- 增加錯誤處理與空畫面設計。
