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
    
    var onFavoriteToggle: ((Product) -> Void)?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(favoriteButton)
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalTo: containerView.widthAnchor, constant: -16),
            
            favoriteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
        product = nil
    }
    
    func configure(with product: Product) {
        self.product = product
        nameLabel.text = product.name
        priceLabel.text = product.formattedPrice
        
        ImageCacheService.shared.loadImage(from: product.imageUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        guard let product = product else { return }
        let isFavorite = favoritesService.isFavorite(productId: product.id)
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func favoriteButtonTapped() {
        guard let product = product else { return }
        onFavoriteToggle?(product)
        updateFavoriteButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.masksToBounds = false
        
        if containerView.layer.shadowPath == nil {
            containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
        }
    }
}
