//
//  SceneDelegate.swift
//  Wordie
//
//  Created by William.Weng on 2026/8/7.
//

import UIKit

final class SceneDelegate: NSObject, UIWindowSceneDelegate {

    /// 主資料庫已存的單字數量
    static var wordCount: Int = 0
    
    /// Scene 建立時呼叫（包含從 Quick Action 冷啟動的情況）
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        initShortcutItems(options: connectionOptions)
    }

    /// App 在背景時，使用者點 Quick Action 會走這個 callback
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    
    /// App 要退到背景 → 這時更新 Quick Actions，符合 Apple 文件建議
    func sceneWillResignActive(_ scene: UIScene) {
        updateShortcutItems()
    }
}

// MARK: - 公用API
extension SceneDelegate {
    
    /// 更新主畫面 Quick Actions
    func updateShortcutItems() {
        
        UIApplication.shared.shortcutItems = [
            ShortcutItemType.appVersion.item,
            ShortcutItemType.lastUsedTime.item,
            ShortcutItemType.wordCount.item,
        ]
    }
}

// MARK: - 私有API
private extension SceneDelegate {
    
    /// 初始化主畫面 Quick Actions，並處理從 Quick Action 冷啟動的情況
    /// - Parameter connectionOptions: Scene 連線時的選項，可能包含 shortcutItem
    func initShortcutItems(options connectionOptions: UIScene.ConnectionOptions) {
        
        updateShortcutItems()
        
        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcut(shortcutItem)
        }
    }
        
    /// 共用的 Quick Action 處理函式
    ///
    /// - Parameter shortcutItem: 使用者選擇的 UIApplicationShortcutItem
    /// - Returns: 是否有成功處理該項目（提供給 completionHandler）
    @discardableResult
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        guard let shortcutType = ShortcutItemType(rawValue: shortcutItem.type) else { return false }
        
        switch shortcutType {
        case .appVersion: print(shortcutItem.type)
        case .lastUsedTime: print(shortcutItem.type)
        case .wordCount: print(shortcutItem.type)
        }
        
        return true
    }
}

