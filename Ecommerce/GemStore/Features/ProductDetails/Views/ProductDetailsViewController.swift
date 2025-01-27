//
//  ProductDetailsViewController.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//

import UIKit
import Combine

class ProductDetailsViewController: UIViewController {
    private let viewModel: ProductDetailsViewModelProtocol
    var hideDefaultNavigationItems: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Colors"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let sizesLabel: UILabel = {
        let label = UILabel()
        label.text = "Sizes"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sizesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private let addToCartAnimationView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addToCartAnimationLabel: UILabel = {
        let label = UILabel()
        label.text = "Added to Cart"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addToCartAnimationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ProductDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if !hideDefaultNavigationItems {
            title = "Product Details"
        }
        setupNavigationBar()
        setupUI()
        setupCollectionViews()
        setupActions()
        setupBindings()
        setupAddToCartAnimation()
        updateUI()
        (viewModel as? ProductDetailsViewModel)?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await (viewModel as? ProductDetailsViewModel)?.checkFavoriteStatus()
            updateUI()
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        navigationItem.hidesBackButton = true
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(colorsLabel)
        contentView.addSubview(colorsCollectionView)
        contentView.addSubview(sizesLabel)
        contentView.addSubview(sizesCollectionView)
        view.addSubview(addToCartButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addToCartButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            colorsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            colorsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            colorsCollectionView.topAnchor.constraint(equalTo: colorsLabel.bottomAnchor, constant: 8),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            sizesLabel.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            sizesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            sizesCollectionView.topAnchor.constraint(equalTo: sizesLabel.bottomAnchor, constant: 8),
            sizesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sizesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sizesCollectionView.heightAnchor.constraint(equalToConstant: 50),
            sizesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            addToCartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addToCartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addToCartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addToCartButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCollectionViews() {
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        colorsCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        
        sizesCollectionView.delegate = self
        sizesCollectionView.dataSource = self
        sizesCollectionView.register(SizeCell.self, forCellWithReuseIdentifier: "SizeCell")
    }
    
    private func setupActions() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.isAddToCartEnabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.addToCartButton.isEnabled = isEnabled
                self?.addToCartButton.backgroundColor = isEnabled ? .black : .gray
            }
            .store(in: &cancellables)
    }
    
    private func setupAddToCartAnimation() {
        view.addSubview(addToCartAnimationView)
        addToCartAnimationView.addSubview(addToCartAnimationLabel)
        addToCartAnimationView.addSubview(addToCartAnimationIcon)
        
        NSLayoutConstraint.activate([
            addToCartAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addToCartAnimationView.bottomAnchor.constraint(equalTo: addToCartButton.topAnchor, constant: -20),
            addToCartAnimationView.widthAnchor.constraint(equalToConstant: 200),
            addToCartAnimationView.heightAnchor.constraint(equalToConstant: 50),
            
            addToCartAnimationIcon.leadingAnchor.constraint(equalTo: addToCartAnimationView.leadingAnchor, constant: 20),
            addToCartAnimationIcon.centerYAnchor.constraint(equalTo: addToCartAnimationView.centerYAnchor),
            addToCartAnimationIcon.widthAnchor.constraint(equalToConstant: 24),
            addToCartAnimationIcon.heightAnchor.constraint(equalToConstant: 24),
            
            addToCartAnimationLabel.leadingAnchor.constraint(equalTo: addToCartAnimationIcon.trailingAnchor, constant: 12),
            addToCartAnimationLabel.centerYAnchor.constraint(equalTo: addToCartAnimationView.centerYAnchor)
        ])
    }
    
    private func showAddToCartAnimation() {
        addToCartAnimationView.transform = CGAffineTransform(translationX: 0, y: 50)
        addToCartAnimationView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.addToCartAnimationView.transform = .identity
            self.addToCartAnimationView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                self.addToCartAnimationView.alpha = 0
                self.addToCartAnimationView.transform = CGAffineTransform(translationX: 0, y: -20)
            })
        }
    }
    
    private func updateUI() {
        let product = viewModel.product
        nameLabel.text = product.name
        priceLabel.text = product.formattedPrice
        descriptionLabel.text = product.description
        
        ImageCacheService.shared.loadImage(from: product.imageUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        
        updateFavoriteButton()
        
        addToCartButton.isEnabled = viewModel.isAddToCartEnabled
        addToCartButton.backgroundColor = viewModel.isAddToCartEnabled ? .black : .gray
        
        colorsCollectionView.reloadData()
        sizesCollectionView.reloadData()
    }
    
    private func updateFavoriteButton() {
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
    }
    
    @objc private func addToCartTapped() {
        viewModel.addToCart()
        showAddToCartAnimation()
    }
}

extension ProductDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorsCollectionView {
            return viewModel.availableColors.count
        } else {
            return viewModel.availableSizes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colorsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            let color = viewModel.availableColors[indexPath.item]
            cell.configure(with: color, isSelected: color == viewModel.selectedColor)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCell", for: indexPath) as! SizeCell
            let size = viewModel.availableSizes[indexPath.item]
            cell.configure(with: size, isSelected: size == viewModel.selectedSize)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorsCollectionView {
            let color = viewModel.availableColors[indexPath.item]
            viewModel.selectColor(color)
        } else {
            let size = viewModel.availableSizes[indexPath.item]
            viewModel.selectSize(size)
        }
    }
}

extension ProductDetailsViewController: ProductDetailsViewModelDelegate {
    func productDetailsViewModelDidUpdate() {
        updateUI()
    }
}

class SizeCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
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
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 8
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with size: String, isSelected: Bool) {
        label.text = size
        contentView.layer.borderColor = isSelected ? UIColor.black.cgColor : UIColor.gray.cgColor
        contentView.backgroundColor = isSelected ? .black : .white
        label.textColor = isSelected ? .white : .black
    }
} 
