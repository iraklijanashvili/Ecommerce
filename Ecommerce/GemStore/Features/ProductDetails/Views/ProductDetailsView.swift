import SwiftUI

struct ProductDetailsView: View {
    @ObservedObject var viewModel: ProductDetailsViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: viewModel.product.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
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
                .frame(height: 300)
                .clipped()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.product.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(viewModel.product.formattedPrice)
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text(viewModel.product.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    
                    if !viewModel.availableColors.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Colors")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.availableColors, id: \.self) { color in
                                        ColorButton(
                                            color: color,
                                            isSelected: viewModel.selectedColor == color,
                                            action: { viewModel.selectColor(color) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    if !viewModel.availableSizes.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Sizes")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.availableSizes, id: \.self) { size in
                                        SizeButton(
                                            size: size,
                                            isSelected: viewModel.selectedSize == size,
                                            action: { viewModel.selectSize(size) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {}) {
                    Text("Add to Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isAddToCartEnabled ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isAddToCartEnabled)
                .padding()
            }
        }
        .navigationBarItems(trailing: FavoriteButton(isFavorite: viewModel.isFavorite) {
            viewModel.toggleFavorite()
        })
    }
}

private struct ColorButton: View {
    let color: ProductColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(color.uiColor))
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .padding(4)
    }
}

private struct SizeButton: View {
    let size: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(size)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(8)
        }
    }
}

private struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(isFavorite ? .red : .gray)
        }
    }
} 
