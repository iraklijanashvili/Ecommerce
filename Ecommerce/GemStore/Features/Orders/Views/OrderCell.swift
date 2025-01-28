//
//  OrderCell.swift
//  Ecommerce
//
//  Created by Imac on 29.01.25.
//

import UIKit

protocol OrderCellDelegate: AnyObject {
    func orderCellDidTapDetails(_ cell: OrderCell)
}

class OrderCell: UITableViewCell {
    weak var delegate: OrderCellDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let orderNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let trackingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [
            createHStack([orderNumberLabel, dateLabel]),
            createHStack([trackingLabel]),
            createHStack([productNameLabel]),
            createHStack([statusLabel])
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        productNameLabel.numberOfLines = 0
        productNameLabel.lineBreakMode = .byWordWrapping
    }
    
    private func createHStack(_ views: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }
    
    func configure(with order: Order) {
        orderNumberLabel.text = "Order #\(String(order.id.prefix(6)))"
        dateLabel.text = order.formattedDate
        trackingLabel.text = "Tracking number: \(String(order.trackingNumber.prefix(6)))"
        productNameLabel.text = order.productName
        
        statusLabel.text = order.status.rawValue
        switch order.status {
        case .pending:
            statusLabel.textColor = .orange
        case .delivered:
            statusLabel.textColor = .green
        case .cancelled:
            statusLabel.textColor = .red
        }
    }
} 
