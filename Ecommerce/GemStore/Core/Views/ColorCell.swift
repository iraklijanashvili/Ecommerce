//
//  ColorCell.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//

import UIKit

class ColorCell: UICollectionViewCell {
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.isHidden = true
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
        contentView.addSubview(colorView)
        colorView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: colorView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 16),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with color: ProductColor, isSelected: Bool) {
        colorView.backgroundColor = color.uiColor
        checkmarkImageView.isHidden = !isSelected
        
        // Add border for white color
        if color == .white {
            colorView.layer.borderWidth = 1
            colorView.layer.borderColor = UIColor.gray.cgColor
        } else {
            colorView.layer.borderWidth = 0
        }
        
        // Add outer ring when selected
        contentView.layer.borderWidth = isSelected ? 2 : 0
        contentView.layer.borderColor = color.uiColor.cgColor
        contentView.layer.cornerRadius = 20
        
        // Show checkmark only on dark colors
        if isSelected {
            switch color {
            case .black, .blue:
                checkmarkImageView.tintColor = .white
            default:
                checkmarkImageView.tintColor = .black
            }
        }
    }
} 