//
//  OrderDetailViewController.swift
//  Ecommerce
//
//  Created by Imac on 29.01.25.
//


import UIKit

class OrderDetailViewController: UIViewController {
    private let viewModel: OrderDetailViewModel
    
    private lazy var navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Details"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .systemGroupedBackground
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var detailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var orderNumberLabel = createDetailLabel(title: "Order number", value: viewModel.orderNumber)
    private lazy var trackingNumberLabel = createDetailLabel(title: "Tracking Number", value: viewModel.trackingNumber)
    private lazy var productNameLabel = createDetailLabel(title: "Product", value: viewModel.productName)
    private lazy var quantityLabel = createDetailLabel(title: "Quantity", value: viewModel.quantity)
    private lazy var subtotalLabel = createDetailLabel(title: "Total", value: viewModel.subtotal)
    private lazy var dateLabel = createDetailLabel(title: "Date", value: viewModel.date)
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.status.rawValue
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switch viewModel.status {
        case .pending:
            label.backgroundColor = .systemYellow.withAlphaComponent(0.2)
            label.textColor = .systemYellow
        case .delivered:
            label.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            label.textColor = .systemGreen
        case .cancelled:
            label.backgroundColor = .systemRed.withAlphaComponent(0.2)
            label.textColor = .systemRed
        }
        
        return label
    }()
    
    init(viewModel: OrderDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.isHidden = true
        navigationItem.hidesBackButton = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupScrollView()
        setupDetailsCard()
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.addSubview(backButton)
        navigationBar.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor)
        ])
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupDetailsCard() {
        contentView.addSubview(detailsCard)
        
        let stackView = UIStackView(arrangedSubviews: [
            orderNumberLabel,
            createSeparator(),
            trackingNumberLabel,
            createSeparator(),
            productNameLabel,
            createSeparator(),
            quantityLabel,
            createSeparator(),
            subtotalLabel,
            createSeparator(),
            dateLabel,
            createSeparator(),
            statusLabel
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        detailsCard.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            detailsCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            detailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -16),
            
            statusLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func createDetailLabel(title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .gray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = .black
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
} 
