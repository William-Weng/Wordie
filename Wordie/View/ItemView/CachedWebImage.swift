//
//  CachedWebImage.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/24.
//

import SwiftUI

struct CachedWebImage<Content: View, Placeholder: View>: View {
    
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var loader = WWWebImageLoader()
    
    var body: some View {
        Group {
            if let uiImage = loader.uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loader.load(from: url)
        }
    }
}
