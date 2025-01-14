//
//  AsyncImageView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI

struct AsyncImageView: View {
    let url: String
    let contentMode: ContentMode
    @StateObject private var imageLoader = AsyncImageViewModel()
    
    init(
        url: String,
        contentMode: ContentMode = .fill
    ) {
        self.url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Color.gray.opacity(0.3)
                    .task {
                        await imageLoader.loadImage(from: url)
                    }
            }
        }
    }
}

@MainActor
final class AsyncImageViewModel: ObservableObject {
    @Published private(set) var image: Image?
    private let imageLoader: ImageLoadable
    
    init(imageLoader: ImageLoadable = DefaultImageLoader()) {
        self.imageLoader = imageLoader
    }
    
    func loadImage(from url: String) async {
        do {
            image = try await imageLoader.loadImage(from: url)
        } catch {
            print("Error loading image: \(error)")
        }
    }
}
