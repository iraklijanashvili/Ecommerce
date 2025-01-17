import UIKit
import SwiftUI
import Combine

class ProductsViewController: UIViewController {
    private let viewModel: ProductViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var contentView: UIHostingController<AnyView> = {
        let hostingController = UIHostingController(
            rootView: AnyView(
                ProductsContentView(viewModel: viewModel)
                    .environmentObject(viewModel)
            )
        )
        return hostingController
    }()
    
    init(categoryId: String) {
        self.viewModel = ProductViewModel(categoryId: categoryId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        Task {
            await viewModel.loadProducts()
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

struct ProductsContentView: View {
    @ObservedObject var viewModel: ProductViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
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
} 