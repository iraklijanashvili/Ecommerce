import UIKit
import SwiftUI
import Combine

class DiscoverViewController: UIViewController {
    private let viewModel = DiscoverViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var contentView: UIHostingController<AnyView> = {
        let hostingController = UIHostingController(
            rootView: AnyView(
                DiscoverContentView(viewModel: viewModel)
                    .environmentObject(viewModel)
            )
        )
        return hostingController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        Task {
            await viewModel.loadData()
        }
    }
    
    private func setupUI() {
        addChild(contentView)
        view.addSubview(contentView.view)
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentView.didMove(toParent: self)
    }
    
    private func setupBindings() {
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

struct DiscoverContentView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            categoriesSection
                            productsGrid
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            )
        }
    }
    
    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 15) {
                ForEach(viewModel.categories) { category in
                    CategoryCell(
                        category: category,
                        isSelected: viewModel.selectedCategory?.id == category.id,
                        onTap: {
                            Task {
                                await viewModel.selectCategory(category)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var productsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ],
            spacing: 15
        ) {
            ForEach(viewModel.products) { product in
                ProductCell(
                    product: product,
                    style: .normal,
                    onTap: {
                        // Handle product selection
                    }
                )
            }
        }
    }
}

struct CategoryCell: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: category.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            
            Text(category.name)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .primary)
        }
    }
} 