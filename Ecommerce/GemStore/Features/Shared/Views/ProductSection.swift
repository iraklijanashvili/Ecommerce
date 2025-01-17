import SwiftUI

struct ProductSection: View {
    let title: String
    let products: [Product]
    let style: ProductCellStyle
    var onProductTap: ((Product) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(products) { product in
                        ProductCell(
                            product: product,
                            style: style,
                            onTap: {
                                onProductTap?(product)
                            }
                        )
                        .frame(width: style == .featured ? 300 : 200)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
} 