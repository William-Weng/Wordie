# Wordie

![SwiftUI](https://img.shields.io/badge/SwiftUI-524520?logo=swift)
[![Swift-5.10](https://img.shields.io/badge/Swift-5.10-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-17.0](https://img.shields.io/badge/iOS-17.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/Wordie)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

Wordie 是一款使用 SwiftUI 製作的英文單字學習 App，提供單字的新增、編輯、刪除與瀏覽功能，並透過 `SQLite` 在本機保存資料，適合作為 `SwiftUI` + `MVVM` + 本地資料庫練習專案，在 `iOS 26` 支援本地 [`AI`](https://www.apple.com/tw/apple-intelligence/) 功能。

![Wordie](https://github.com/user-attachments/assets/3d097a82-3278-4a05-a17d-3054c498bfe0) ![Wordie-AI](https://github.com/user-attachments/assets/79824c3e-04ec-4bfb-8030-a59e5ec2f690)

![Kirie](https://github.com/user-attachments/assets/ed4a3d57-7d8e-48bc-a5d1-087da9598ead) ![Kirie-AI](https://github.com/user-attachments/assets/4a80f7d3-8d97-45c3-8eaa-fb0cad4c9b26)

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

## Info.plist
- 記得要設定，在Finder / iPhone才能放文件資訊

```xml
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UISupportsDocumentBrowser</key>
<true/>
```

## 引用字型

| 名稱 | 說明 |
|------|------|
| [`PlaypenSans-VariableFont_wght.ttf`](https://fonts.google.com/specimen/Playpen+Sans) | 英文字型 |
| [`jf-openhuninn-2.1.ttf`](https://justfont.com/huninn/) | 中文字型 |
| [`KleeOne-Regular.ttf`](https://fonts.google.com/specimen/Klee+One) | 日文字型 |

- 如果要引用字型，記得在 `.documentsDirectory` 上加上 	`config.json` 設定檔	

![documentsDirectory](https://github.com/user-attachments/assets/55e66e0c-6262-4459-bd1b-deae5dd92d74)

```json
{
  "Font": {
    "word": {
      "ttf": "KleeOne-SemiBold.ttf",
      "size": 48.0
    },
    "reading": {
      "ttf": "KleeOne-SemiBold.ttf",
      "size": 28.0
    },
    "chinese":
    {
      "ttf": "jf-openhuninn-2.1.ttf",
      "size": 32.0
    }
  }
}
```

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

## [引用套件](https://swiftpackageindex.com/William-Weng)

| 項目 | 說明 |
|------|------|
| [WWCacheManager](https://github.com/William-Weng/WWCacheManager) | 一個高效、線程安全的快取管理器，支援 `DispatchQueue` 讀寫鎖和 `@propertyWrapper` 語法 |
| [WWFlipWordCardUI](https://github.com/William-Weng/WWFlipWordCardUI) | 一個基於 SwiftUI 的單字卡元件，支援翻頁式卡片互動，適合用於單字學習、語言學習與教育類 App |
| [WWFontLoader](https://github.com/William-Weng/WWFontLoader) | iOS 字型載入器 - 支援系統內建字型和外部的 TTF 字型檔案，自動註冊並提供全域 Font 存取 |
| [WWHUDUI](https://github.com/William-Weng/WWHUDUI) | 一個用 SwiftUI 製作的簡單 HUD（Head-Up Display）元件 |
| [WWIntelligentAgent](https://github.com/William-Weng/WWIntelligentAgent) | 一個以 **Apple Foundation Models** 為基礎的輕量級 Swift 包裝器 |
| [WWMarkdownWebViewUI](https://github.com/William-Weng/WWMarkdownWebViewUI) | 使用 `WKWebView` 在 SwiftUI 中渲染 `Markdown`，支援動態高度 |
| [WWSafariViewUI](https://github.com/William-Weng/WWSafariViewUI) | 是一個以 SwiftUI 包裝 `SFSafariViewController` 的輕量元件 |
| [WWSQLite3Manager](https://github.com/William-Weng/WWSQLite3Manager) | 一套輕量級的 Swift SQLite3 工具 |
| [WWWebImage](https://github.com/William-Weng/WWWebImage) | 簡易的非同步網路圖片下載工具 |
