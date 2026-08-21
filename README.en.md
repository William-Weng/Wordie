[English](./README.en.md) | [正體中文](./README.md)

# [Wordie](https://swiftpackageindex.com/William-Weng)

![SwiftUI](https://img.shields.io/badge/SwiftUI-524520?logo=swift)
[![Swift-5.10](https://img.shields.io/badge/Swift-5.10-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-17.0](https://img.shields.io/badge/iOS-17.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/Wordie)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

Wordie is an English vocabulary learning app built with SwiftUI. It provides features for adding, editing, deleting, and browsing vocabulary words, while storing data locally using `SQLite`. The project is suitable for practicing `SwiftUI`, `MVVM`, and local database integration, and supports on-device [`AI`](https://www.apple.com/tw/apple-intelligence/) features on `iOS 26`.

<img width="256" alt="Wordie" src="https://github.com/user-attachments/assets/9ade8dd8-bf22-4d21-a40e-323c9e702fc6" />

<img width="256" alt="Wordie-AI" src="https://github.com/user-attachments/assets/79824c3e-04ec-4bfb-8030-a59e5ec2f690" />

<img width="256" alt="Wordie-2" src="https://github.com/user-attachments/assets/60cbae05-d4bd-4412-b9f5-ac2fcf1d1d53" />

<img width="256" alt="Kirie" src="https://github.com/user-attachments/assets/5ffa1a79-f8b6-496f-b036-9f86f711bdf8" />

<img width="256" alt="Kirie-AI" src="https://github.com/user-attachments/assets/83246189-0c98-4eb6-92f6-2106458a1947" />

<img width="256" alt="Kirie-2" src="https://github.com/user-attachments/assets/8d23c1e6-e8d6-4194-9b05-b7c71e9b9870" />

## [Screen Features](https://peterpanswift.github.io/iphone-bezels/)

### [Home](https://medium.com/在程式與旅行的路上/widget-extension-等到-ios-14-才姍姍來遲的-widget-小工具-7b269d9b2253)
- Displays the current vocabulary word.
- Allows users to switch between word-browsing states.
- Provides entry points for adding, editing, and deleting words.

### Add / Edit Words
- Enter an English word, phonetic transcription, and Chinese definition.
- Existing data is automatically populated in edit mode.
- Submission is available only after all fields pass validation.

## Technologies

| Item | Description |
|------|-------------|
| UI Framework | `SwiftUI` |
| Architecture | `MVVM` |
| Data Storage | `SQLite` |
| Language | `Swift` |

## Info.plist

- Remember to configure the following settings so documents can be accessed through Finder and on the iPhone.

```xml
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UISupportsDocumentBrowser</key>
<true/>
```

## Fonts

| Name | Description |
|------|-------------|
| [`PlaypenSans-VariableFont_wght.ttf`](https://fonts.google.com/specimen/Playpen+Sans) | English font |
| [`jf-openhuninn-2.1.ttf`](https://justfont.com/huninn/) | Chinese font |
| [`KleeOne-Regular.ttf`](https://fonts.google.com/specimen/Klee+One) | Japanese font |

- To use custom fonts, add a `config.json` configuration file to `.documentsDirectory`.

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
    "chinese": {
      "ttf": "jf-openhuninn-2.1.ttf",
      "size": 32.0
    }
  }
}
```

## How to Run

1. Open the project in Xcode.
2. Select a simulator or a physical device.
3. Build and run the app.
4. After opening the home screen, you can add, edit, and delete vocabulary words.

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
                    instructions: "You are an English teacher who helps people explain English vocabulary."
                )
            )
        }
    }
}
```

## Core Workflows

### Reading Data
- `WordListViewModel` calls `API.shared.select()` to retrieve vocabulary words from the database.
- After the data is loaded, `words` is updated so the UI refreshes automatically.

### Adding Data
- After entering the data in `AddWordView`, call `viewModel.addWord(...)`.
- `WordListViewModel` then writes the data to the database through `API.shared.insert(...)`.

### Editing Data
- In edit mode, the existing word data is populated first.
- After confirmation, call `updateWord(...)` to update the content in SQLite.

### Deleting Data
- After selecting delete from the main screen, call `deleteWord(...)` or delete the corresponding ID.
- Reload the list after the deletion succeeds.

## Learning Objectives

This project is well suited for practicing the following topics:

- Splitting SwiftUI screens and extracting reusable components.
- Using `@State`, `@Binding`, `@ObservedObject`, and `@StateObject`.
- Common SwiftUI UI flows such as sheets, toolbars, alerts, and confirmation dialogs.
- Separation of responsibilities between the ViewModel and the data-access layer.
- Basic SQLite CRUD operations.

## Possible Improvements

- Add search functionality.
- Add quiz mode or flashcard mode.
- Support importing and exporting vocabulary data.
- Improve error handling and empty-state design.

## [Referenced Packages](https://swiftpackageindex.com/William-Weng)

| Package | Description |
|---------|-------------|
| [WWDetectDevice](https://github.com/William-Weng/WWDetectDevice) | A utility package for identifying Apple device models, model information, and screen corner radii. |
| [WWFlipWordCardUI](https://github.com/William-Weng/WWFlipWordCardUI) | A SwiftUI vocabulary card component that supports page-flip card interactions, suitable for vocabulary learning, language learning, and educational apps. |
| [WWFontLoader](https://github.com/William-Weng/WWFontLoader) | An iOS font loader that supports system fonts and external TTF files, automatically registers them, and provides global Font access. |
| [WWHUDUI](https://github.com/William-Weng/WWHUDUI) | A simple HUD (Head-Up Display) component built with SwiftUI. |
| [WWIntelligentAgent](https://github.com/William-Weng/WWIntelligentAgent) | A lightweight Swift wrapper based on **Apple Foundation Models**. |
| [WWMarkdownWebViewUI](https://github.com/William-Weng/WWMarkdownWebViewUI) | Renders `Markdown` in SwiftUI using `WKWebView`, with support for dynamic height. |
| [WWSafariViewUI](https://github.com/William-Weng/WWSafariViewUI) | A lightweight SwiftUI wrapper around `SFSafariViewController`. |
| [WWSQLite3Manager](https://github.com/William-Weng/WWSQLite3Manager) | A lightweight Swift SQLite3 utility. |
| [WWWebImage](https://github.com/William-Weng/WWWebImage) | A simple asynchronous network image downloader. |