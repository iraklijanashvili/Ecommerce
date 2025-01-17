import SwiftUI

struct ProductCell: View {
    let product: Product
    var style: ProductCellStyle = .normal
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: product.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: style.imageContentMode)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: style.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(style.titleFont)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(product.formattedPrice)
                        .font(style.priceFont)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

enum ProductCellStyle {
    case normal
    case compact
    case featured
    
    var imageHeight: CGFloat {
        switch self {
        case .normal: return 200
        case .compact: return 150
        case .featured: return 250
        }
    }
    
    var imageContentMode: ContentMode {
        switch self {
        case .normal, .compact: return .fill
        case .featured: return .fit
        }
    }
    
    var titleFont: Font {
        switch self {
        case .normal: return .headline
        case .compact: return .subheadline
        case .featured: return .title3
        }
    }
    
    var priceFont: Font {
        switch self {
        case .normal, .compact: return .subheadline
        case .featured: return .headline
        }
    }
} 