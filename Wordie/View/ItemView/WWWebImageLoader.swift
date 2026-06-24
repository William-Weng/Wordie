//
//  WWWebImageLoader.swift
//  Wordie
//
//  Created by iOS on 2026/6/24.
//

import SwiftUI
import WWWebImage

@MainActor
@Observable
final class WWWebImageLoader {
    
    var uiImage: UIImage?
    var isLoading = false
    
    func load(from url: URL?) async {
        guard let url else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let imageView = UIImageView()
            try await imageView.ww.download(urlString: url.absoluteString)
            self.uiImage = imageView.image
        } catch {
            self.uiImage = nil
        }
    }
}
