import SwiftUI

struct HomeCategorySection: View {
    let categories: [Category]
    @State private var selectedCategoryId: String?
    var onCategorySelect: ((Category) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(categories) { category in
                        CategoryCell(
                            category: category,
                            isSelected: category.id == selectedCategoryId,
                            onTap: {
                                selectedCategoryId = category.id
                                onCategorySelect?(category)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
} 