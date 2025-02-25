//
//  ProductCell.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//

import UIKit

class ProductCell: UICollectionViewCell {
    private var product: Product?
    private let favoritesService = FavoritesServiceImpl.shared
    var showFavoriteButton: Bool = false {
        didSet {
            favoriteButton.isHidden = !showFavoriteButton
        }
    }
    
    var onFavoriteToggle: ((Product) -> Void)?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.masksToBounds = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(favoriteButton)
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
        product = nil
    }
    
    func configure(with product: Product, showFavorite: Bool = false) {
        self.product = product
        self.showFavoriteButton = showFavorite
        titleLabel.text = product.name
        priceLabel.text = "$\(Int(product.price))"
        
        UnifiedCacheService.shared.loadImage(from: product.defaultImageUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        
        if showFavorite {
            updateFavoriteButton()
        }
    }
    
    private func updateFavoriteButton() {
        guard let product = product else { return }
        Task {
            do {
                let isFavorite = try await favoritesService.isFavorite(productId: product.id)
                DispatchQueue.main.async { [weak self] in
                    let imageName = isFavorite ? "heart.fill" : "heart"
                    self?.favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
                }
            } catch {
                print("Error checking favorite status: \(error)")
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {
        guard let product = product else { return }
        Task {
            do {
                let isFavorite = try await favoritesService.isFavorite(productId: product.id)
                if isFavorite {
                    try await favoritesService.removeFavorite(productId: product.id)
                } else {
                    try await favoritesService.addFavorite(product: product)
                }
                await MainActor.run {
                    onFavoriteToggle?(product)
                    updateFavoriteButton()
                }
            } catch {
                print("Error toggling favorite: \(error)")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
