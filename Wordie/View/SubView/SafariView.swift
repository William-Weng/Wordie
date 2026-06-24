//
//  SafariView.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import Foundation

import SwiftUI
import SafariServices
import WWWebImage

struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UIColor.systemBlue
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}
