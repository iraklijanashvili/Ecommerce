//
//  DiscoverViewController.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import UIKit

class DiscoverViewController: UIViewController {
private let viewModel: DiscoverViewModelProtocol
private var isShowingFilteredProducts = false
private var currentCategoryId: String?

private let backButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    button.tintColor = .black
    button.isHidden = true
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
}()

private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search"
    searchBar.searchBarStyle = .minimal
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    return searchBar
}()

private let filterButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
    button.tintColor = .black
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
}()

private let searchContainer: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
}()

private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 1
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
}()

private var expandedCategoryId: String?

private let emptyStateView: UIView = {
    let view = UIView()
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isUserInteractionEnabled = false
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 12
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    imageView.tintColor = .gray
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: 60),
        imageView.heightAnchor.constraint(equalToConstant: 60)
    ])
    
    let label = UILabel()
    label.text = "No products found"
    label.textColor = .gray
    label.font = .systemFont(ofSize: 16)
    label.textAlignment = .center
    
    let descriptionLabel = UILabel()
    descriptionLabel.text = "Try adjusting your filters or search criteria"
    descriptionLabel.textColor = .gray
    descriptionLabel.font = .systemFont(ofSize: 14)
    descriptionLabel.textAlignment = .center
    
    stackView.addArrangedSubview(imageView)
    stackView.addArrangedSubview(label)
    stackView.addArrangedSubview(descriptionLabel)
    
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    return view
}()

init(viewModel: DiscoverViewModelProtocol = DiscoverViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
}

required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
    viewModel.fetchCategories()
    viewModel.fetchAllProducts()
    
    view.insertSubview(emptyStateView, aboveSubview: collectionView)
    NSLayoutConstraint.activate([
        emptyStateView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
        emptyStateView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
        emptyStateView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor),
        emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
}

private func setupUI() {
    view.backgroundColor = .white
    navigationController?.setNavigationBarHidden(true, animated: false)
    
    view.addSubview(searchContainer)
    searchContainer.addSubview(backButton)
    searchContainer.addSubview(searchBar)
    searchContainer.addSubview(filterButton)
    view.addSubview(collectionView)
    
    searchBar.delegate = self
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
    collectionView.register(SubcategoryCell.self, forCellWithReuseIdentifier: "SubcategoryCell")
    collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
    
    filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    
    NSLayoutConstraint.activate([
        searchContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        searchContainer.heightAnchor.constraint(equalToConstant: 60),
        
        backButton.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 16),
        backButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
        backButton.widthAnchor.constraint(equalToConstant: 44),
        backButton.heightAnchor.constraint(equalToConstant: 44),
        
        searchBar.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
        searchBar.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -8),
        searchBar.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
        
        filterButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -16),
        filterButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
        filterButton.widthAnchor.constraint(equalToConstant: 44),
        filterButton.heightAnchor.constraint(equalToConstant: 44),
        
        collectionView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor),
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
}

@objc private func filterButtonTapped() {
    currentCategoryId = nil
    viewModel.fetchAllProducts()
    
    let filterVC = FilterViewController(currentFilter: viewModel.currentFilter)
    filterVC.delegate = self
    filterVC.modalPresentationStyle = .overFullScreen
    present(filterVC, animated: true)
}

@objc private func backButtonTapped() {
    isShowingFilteredProducts = false
    currentCategoryId = nil
    backButton.isHidden = true
    viewModel.resetFilter()
    viewModel.fetchAllProducts()
    collectionView.reloadData()
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

extension DiscoverViewController: FilterViewControllerDelegate {
func filterViewController(_ controller: FilterViewController, didApplyFilter filter: FilterOptions) {
    currentCategoryId = nil
    viewModel.applyFilter(filter)
    isShowingFilteredProducts = true
    backButton.isHidden = false
    collectionView.reloadData()
}

func filterViewControllerDidReset(_ controller: FilterViewController) {
    currentCategoryId = nil
    viewModel.resetFilter()
    isShowingFilteredProducts = false
    backButton.isHidden = true
    collectionView.reloadData()
}
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
func numberOfSections(in collectionView: UICollectionView) -> Int {
    let sections = isShowingFilteredProducts ? 1 : viewModel.categories.count
    let isEmpty = isShowingFilteredProducts && viewModel.filteredProducts.isEmpty
    
    emptyStateView.isHidden = !isEmpty
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = viewModel.filteredProducts[indexPath.item]
        cell.configure(with: product)
        
        cell.onFavoriteToggle = { [weak self] product in
            if FavoritesServiceImpl.shared.isFavorite(productId: product.id) {
                FavoritesServiceImpl.shared.removeFavorite(productId: product.id)
            } else {
                FavoritesServiceImpl.shared.addFavorite(product: product)
            }
            cell.configure(with: product)
        }
        
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.shadowColor = UIColor.black.cgColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.contentView.layer.shadowRadius = 6
        cell.contentView.layer.shadowOpacity = 0.1
        cell.contentView.layer.masksToBounds = false
        
        cell.contentView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
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
        
        UIView.performWithoutAnimation {
            collectionView.reloadSections(sectionsToReload)
        }
    } else {
        expandedCategoryId = nil
        let subcategory = category.subcategoryArray[indexPath.item - 1]
        currentCategoryId = subcategory.id
        viewModel.resetFilter()
        viewModel.fetchProducts(for: subcategory.id)
        isShowingFilteredProducts = true
        backButton.isHidden = false
        collectionView.reloadData()
    }
}
}

extension DiscoverViewController: UISearchBarDelegate {
func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if !searchText.isEmpty {
        currentCategoryId = nil
        isShowingFilteredProducts = true
        backButton.isHidden = false
        viewModel.search(query: searchText)
    } else {
        isShowingFilteredProducts = false
        backButton.isHidden = true
        viewModel.resetFilter()
    }
    collectionView.reloadData()
}

func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
}

func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
    isShowingFilteredProducts = false
    currentCategoryId = nil
    backButton.isHidden = true
    viewModel.resetFilter()
    collectionView.reloadData()
}
}

class CategoryCell: UICollectionViewCell {
private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
}()

private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 24, weight: .bold)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
}

required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

private func setupUI() {
    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
}

func configure(with category: Category) {
    titleLabel.text = category.name.uppercased()
    if let url = URL(string: category.imageUrl) {
        ImageCacheService.shared.loadImage(from: category.imageUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }
}

override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
    titleLabel.text = nil
}
}

class SubcategoryCell: UICollectionViewCell {
private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

private let chevronImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "chevron.right")
    imageView.tintColor = .gray
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
}()

override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
}

required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

private func setupUI() {
    contentView.backgroundColor = .white
    
    contentView.addSubview(titleLabel)
    contentView.addSubview(chevronImageView)
    
    NSLayoutConstraint.activate([
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        
        chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        chevronImageView.widthAnchor.constraint(equalToConstant: 20),
        chevronImageView.heightAnchor.constraint(equalToConstant: 20)
    ])
    
    let separator = UIView()
    separator.backgroundColor = .systemGray5
    separator.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(separator)
    
    NSLayoutConstraint.activate([
        separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        separator.heightAnchor.constraint(equalToConstant: 1)
    ])
}

func configure(with subcategory: Category.Subcategory) {
    titleLabel.text = subcategory.name
}

override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
}
}
