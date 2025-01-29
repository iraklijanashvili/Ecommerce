import SwiftUI

struct AsyncProductImageView: View {
    let imageUrl: String
    let contentMode: ContentMode
    let width: CGFloat?
    let height: CGFloat
    
    init(
        imageUrl: String,
        contentMode: ContentMode = .fill,
        width: CGFloat? = nil,
        height: CGFloat
    ) {
        self.imageUrl = imageUrl
        self.contentMode = contentMode
        self.width = width
        self.height = height
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                Color.gray
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }
} 