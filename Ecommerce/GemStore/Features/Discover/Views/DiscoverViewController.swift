//
//  DiscoverViewController.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import UIKit

class DiscoverViewController: UIViewController {
    private let viewModel: DiscoverViewModelProtocol
    private let favoritesService: FavoritesService
    private var isShowingFilteredProducts = false
    private var currentCategoryId: String?
    var expandedCategoryId: String?
    
    private let searchView = DiscoverSearchView()
    private let emptyStateView = DiscoverEmptyStateView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(viewModel: DiscoverViewModelProtocol = DiscoverViewModel(), 
         favoritesService: FavoritesService = FavoritesServiceImpl.shared) {
        self.viewModel = viewModel
        self.favoritesService = favoritesService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectCategory(_ category: Category) {
        expandedCategoryId = nil
        currentCategoryId = nil
        isShowingFilteredProducts = false
        collectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.expandedCategoryId = category.id
            
            if let index = self.viewModel.categories.firstIndex(where: { $0.id == category.id }) {
                let indexPath = IndexPath(item: 0, section: index)
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                
                let isLastCategory = index == self.viewModel.categories.count - 1
                
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.reloadSections(IndexSet(integer: index))
                    }) { _ in
                        if isLastCategory {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let contentHeight = self.collectionView.contentSize.height
                                let visibleHeight = self.collectionView.bounds.height
                                let bottomOffset = max(0, contentHeight - visibleHeight)
                                
                                self.collectionView.setContentOffset(
                                    CGPoint(x: 0, y: bottomOffset),
                                    animated: true
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchCategories()
        viewModel.fetchAllProducts()
        
        if let savedCategoryData = UserDefaults.standard.data(forKey: "selectedCategory"),
           let savedCategory = try? JSONDecoder().decode(Category.self, from: savedCategoryData) {
            UserDefaults.standard.removeObject(forKey: "selectedCategory")
            selectCategory(savedCategory)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        searchView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        
        view.addSubview(searchView)
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        
        searchView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        collectionView.register(SubcategoryCell.self, forCellWithReuseIdentifier: "SubcategoryCell")
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchView.heightAnchor.constraint(equalToConstant: 60),
            
            collectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            emptyStateView.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.onProductsUpdated = { [weak self] in
            if self?.isShowingFilteredProducts == true {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            self?.showError(error)
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension DiscoverViewController: DiscoverSearchViewDelegate {
    func searchViewDidTapBack() {
        isShowingFilteredProducts = false
        currentCategoryId = nil
        searchView.setBackButtonVisible(false)
        viewModel.resetFilter()
        viewModel.fetchAllProducts()
        collectionView.reloadData()
    }
    
    func searchViewDidTapFilter() {
        currentCategoryId = nil
        viewModel.fetchAllProducts()
        
        let filterVC = FilterViewController(currentFilter: viewModel.currentFilter)
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .overFullScreen
        present(filterVC, animated: true)
    }
    
    func searchView(_ searchView: DiscoverSearchView, didUpdateSearchText text: String) {
        if text.isEmpty {
            isShowingFilteredProducts = false
            currentCategoryId = nil
            searchView.setBackButtonVisible(false)
            viewModel.resetFilter()
            viewModel.fetchAllProducts()
        } else {
            viewModel.search(query: text)
            isShowingFilteredProducts = true
            searchView.setBackButtonVisible(true)
        }
        collectionView.reloadData()
    }
}

extension DiscoverViewController: FilterViewControllerDelegate {
    func filterViewController(_ controller: FilterViewController, didApplyFilter filter: FilterOptions) {
        currentCategoryId = nil
        viewModel.applyFilter(filter)
        isShowingFilteredProducts = true
        searchView.setBackButtonVisible(true)
        collectionView.reloadData()
    }
    
    func filterViewControllerDidReset(_ controller: FilterViewController) {
        currentCategoryId = nil
        viewModel.resetFilter()
        isShowingFilteredProducts = false
        searchView.setBackButtonVisible(false)
        collectionView.reloadData()
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sections = isShowingFilteredProducts ? 1 : viewModel.categories.count
        let isEmpty = isShowingFilteredProducts && viewModel.filteredProducts.isEmpty
        emptyStateView.isHidden = !isEmpty
        
        collectionView.isHidden = isEmpty
        
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isShowingFilteredProducts {
            return viewModel.filteredProducts.count
        }
        
        let category = viewModel.categories[section]
        if category.id == expandedCategoryId {
            return 1 + category.subcategoryArray.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isShowingFilteredProducts {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
                return UICollectionViewCell()
            }
            
            let product = viewModel.filteredProducts[indexPath.item]
            cell.configure(with: product, showFavorite: false)
            return cell
        }
        
        let category = viewModel.categories[indexPath.section]
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.configure(with: category)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubcategoryCell", for: indexPath) as! SubcategoryCell
            let subcategory = category.subcategoryArray[indexPath.item - 1]
            cell.configure(with: subcategory)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isShowingFilteredProducts {
            let padding: CGFloat = 32
            let spacing: CGFloat = 8
            let availableWidth = collectionView.bounds.width - padding
            let itemWidth = (availableWidth - spacing) / 2
            return CGSize(width: itemWidth, height: itemWidth * 1.5)
        }
        
        if indexPath.item == 0 {
            return CGSize(width: collectionView.bounds.width, height: 200)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return isShowingFilteredProducts ? 8 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return isShowingFilteredProducts ? 16 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if isShowingFilteredProducts {
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isShowingFilteredProducts {
            let product = viewModel.filteredProducts[indexPath.item]
            let viewModel = ProductDetailsViewModel(product: product)
            let productDetailsVC = ProductDetailsViewController(viewModel: viewModel)
            navigationController?.pushViewController(productDetailsVC, animated: true)
            return
        }
        
        let category = viewModel.categories[indexPath.section]
        if indexPath.item == 0 {
            let wasExpanded = (expandedCategoryId == category.id)
            let previouslyExpandedId = expandedCategoryId
            expandedCategoryId = wasExpanded ? nil : category.id
            
            var sectionsToReload = IndexSet(integer: indexPath.section)
            if let previousSection = viewModel.categories.firstIndex(where: { $0.id == previouslyExpandedId }) {
                sectionsToReload.insert(previousSection)
            }
            
            let isLastCategory = indexPath.section == viewModel.categories.count - 1
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.reloadSections(sectionsToReload)
                }) { _ in
                    if !wasExpanded {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            
                            let targetIndexPath = IndexPath(item: 1, section: indexPath.section)
                            if let attributes = self.collectionView.layoutAttributesForItem(at: targetIndexPath) {
                                let targetRect = attributes.frame
                                
                                if isLastCategory {
                                    let extraScroll: CGFloat = 200
                                    let adjustedRect = CGRect(
                                        x: targetRect.origin.x,
                                        y: targetRect.origin.y,
                                        width: targetRect.width,
                                        height: targetRect.height + extraScroll
                                    )
                                    self.collectionView.scrollRectToVisible(adjustedRect, animated: true)
                                } else {
                                    self.collectionView.scrollRectToVisible(targetRect, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            expandedCategoryId = nil
            let subcategory = category.subcategoryArray[indexPath.item - 1]
            currentCategoryId = subcategory.id
            
            print("\n🔍 Selected subcategory:")
            print("- Category ID: \(category.id)")
            print("- Subcategory ID: \(subcategory.id)")
            print("- Subcategory name: \(subcategory.name)")
            
            if subcategory.name.lowercased() == "all" {
                print("📦 Fetching all products for category: \(category.id)")
                let fullPath = "\(category.id)/all"
                viewModel.fetchProducts(for: fullPath)
            } else {
                print("🔍 Fetching products for subcategory: \(subcategory.id)")
                let fullPath = subcategory.id.lowercased()
                viewModel.fetchProducts(for: fullPath)
            }
            
            isShowingFilteredProducts = true
            searchView.setBackButtonVisible(true)
            collectionView.reloadData()
        }
    }
}
