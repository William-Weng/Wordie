# Wordie SwiftUI State Guide

## 1) Property Wrapper Guide

| 名稱 | 用途 | 由誰管理 | 典型情境 | 你在 Wordie 的用法 |
|---|---|---|---|---|
| `@State` | 管理畫面自己的狀態 | 當前 View | 輸入文字、開關、索引、翻牌狀態 | `english`、`phonetic`、`chinese`、`isFlipped`、`currentIndex` |
| `@Binding` | 接收父層傳下來且可被修改的值 | 父 View | 子畫面要改父畫面的狀態 | 子卡片或子元件修改父層資料時 |
| `@ObservedObject` | 觀察外部的可變物件 | 外部 ViewModel | ViewModel 資料更新後，畫面跟著刷新 | `AddWordView(viewModel:)` |
| `@StateObject` | 在這個 View 內建立並持有 ViewModel | 當前 View | 畫面自己擁有資料管理者 | `WordieHomeView` 持有 `WordListViewModel()` |
| `@Environment` | 從系統或上層環境讀值 | SwiftUI 環境 | 關閉畫面、讀色彩模式、讀語系 | `@Environment(\.dismiss)` |
| `@EnvironmentObject` | 從環境中讀共享物件 | 父層注入 | 多層 view 共用同一份狀態 | 未來若整個 Wordie 共用同一個資料中心 |
| `@Published` | 通知畫面資料已改變 | ViewModel 內部 | 讓 `ObservableObject` 觸發更新 | `@Published var words: [Word]` |

## 2) Wordie Architecture Flow

```text
[App Launch]
      |
      v
[WordieHomeView]
      |
      |-- owns --> [WordListViewModel]  (@StateObject)
      |                  |
      |                  |-- loads / inserts --> [API]
      |                  |                         |
      |                  |                         |-- reads / writes --> [SQLite DB]
      |                  |
      |                  |-- publishes --> words (@Published)
      |
      |-- displays --> [WordieContentView]
      |                  |
      |                  |-- shows card / swipe / flip UI
      |                  |-- reads words from ViewModel
      |
      |-- presents --> [AddWordView]  (.sheet)
                         |
                         |-- edits local fields (@State)
                         |-- calls viewModel.addWord(...)
                         |-- dismisses via @Environment(\.dismiss)

[After Save]
      |
      v
[WordListViewModel.addWord]
      |
      |-- API.shared.insert(...)
      |-- loadWords()
      |
      v
[words updated]
      |
      v
[WordieContentView refreshes automatically]
```

## 3) Quick Rules

- `@State` = 畫面自己的暫存資料。
- `@Binding` = 父子共享且可回寫。
- `@ObservedObject` = 觀察別人的 ViewModel。
- `@StateObject` = 自己擁有的 ViewModel。
- `@Environment` = 系統或上層提供的值。
- `@Published` = ViewModel 改變時通知 SwiftUI 刷新。

## 4) Wordie Data Flow Summary

1. App 開啟後，`WordieHomeView` 建立 `WordListViewModel`。
2. `WordListViewModel.loadWords()` 從 `API` 讀 SQLite 資料。
3. `words` 更新後，`WordieContentView` 自動刷新。
4. 使用者按右上角 `+`，畫面開啟 `AddWordView`。
5. `AddWordView` 先用 `@State` 存輸入內容。
6. 按下儲存後呼叫 `viewModel.addWord(...)`。
7. `addWord()` 寫入資料庫後再重新 `loadWords()`。
8. `words` 更新，首頁卡片內容立即同步。

## 5) Reminder

- 主畫面持有 ViewModel 時，用 `@StateObject`。
- 子畫面只使用 ViewModel 時，用 `@ObservedObject`。
- 畫面內部輸入文字，通常用 `@State`。
- 系統提供的 dismiss / colorScheme 等值，用 `@Environment`。

## 6) 三個角色記法

```txt
父層
 ├─ @State        = 我自己擁有的值
 ├─ @StateObject  = 我自己擁有的 ViewModel
 └─ 把值往下傳給子層

子層
 ├─ @Binding      = 父層給我，我可以改回去
 └─ @ObservedObject = 我只是觀察 ViewModel
```
