import SwiftUI

enum ProductCardStyle {
    case regular
    case compact
    case featured
    case grid
    
    var dimensions: (width: CGFloat?, height: CGFloat) {
        switch self {
        case .regular:
            return (width: 150, height: 200)
        case .compact:
            return (width: 213, height: 66)
        case .featured:
            return (width: 180, height: 240)
        case .grid:
            return (width: nil, height: 200)
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .regular:
            return 10
        case .compact:
            return 8
        case .featured:
            return 12
        case .grid:
            return 10
        }
    }
    
    var titleFont: Font {
        switch self {
        case .regular:
            return .caption
        case .compact:
            return .system(size: 14)
        case .featured:
            return .system(size: 16)
        case .grid:
            return .subheadline
        }
    }
    
    var priceFont: Font {
        switch self {
        case .regular:
            return .caption
        case .compact:
            return .system(size: 16, weight: .bold)
        case .featured:
            return .system(size: 18, weight: .bold)
        case .grid:
            return .headline
        }
    }
}

struct BaseProductCard: View {
    let product: Product
    let style: ProductCardStyle
    
    var body: some View {
        VStack(alignment: .leading, spacing: style == .compact ? 0 : 8) {
            if style == .compact {
                HStack(spacing: 0) {
                    AsyncProductImageView(
                        imageUrl: product.defaultImageUrl,
                        width: 66,
                        height: 66
                    )
                    
                    productInfo
                        .padding(.horizontal, 12)
                    
                    Spacer()
                }
            } else {
                AsyncProductImageView(
                    imageUrl: product.defaultImageUrl,
                    width: style.dimensions.width,
                    height: style.dimensions.height
                )
                
                productInfo
                    .padding(.horizontal, style == .grid ? 8 : 0)
            }
        }
        .frame(width: style.dimensions.width)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .cornerRadius(style.cornerRadius)
        .shadow(
            color: Color.black.opacity(0.1),
            radius: style == .compact ? 3 : 4,
            x: 0,
            y: 2
        )
    }
    
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.name)
                .font(style.titleFont)
                .foregroundColor(.black)
                .lineLimit(style == .regular ? 1 : 2)
            
            Text(product.formattedPrice)
                .font(style.priceFont)
                .foregroundColor(.black)
        }
    }
} 