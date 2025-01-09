import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Text("Gemstore")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.title2)
                        }
                    }
                    .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            CategoryButton(title: "Women", icon: "♀", isSelected: true)
                            CategoryButton(title: "Men", icon: "♂")
                            CategoryButton(title: "Accessories", icon: "👓")
                            CategoryButton(title: "Beauty", icon: "💄")
                        }
                        .padding(.horizontal)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                        
                        VStack(alignment: .leading) {
                            Text("Autumn")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Collection")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("2022")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Feature Products")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button("Show all") {
                        }
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.products) { product in
                                ProductCard(product: product)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct CategoryButton: View {
    let title: String
    let icon: String
    var isSelected: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.black : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text(icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .black)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .black : .gray)
        }
    }
}

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.2)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color.red
                @unknown default:
                    Color.blue
                }
            }
            .frame(width: 150, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(product.name)
                .font(.headline)
            
            Text("$ \(String(format: "%.2f", product.price))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 150)
    }
}
