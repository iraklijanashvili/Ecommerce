//
//  FilterViewController.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//


import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ controller: FilterViewController, didApplyFilter filter: FilterOptions)
    func filterViewControllerDidReset(_ controller: FilterViewController)
}

class FilterViewController: UIViewController {
    private let viewModel: FilterViewModel
    weak var delegate: FilterViewControllerDelegate?
    
    private var isCategoriesExpanded = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.categoriesTableView.isHidden = !self.isCategoriesExpanded
            }
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Price Range"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceRangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceRangeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1000
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let sortingLabel: UILabel = {
        let label = UILabel()
        label.text = "Sort By Price"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sortingControl: UISegmentedControl = {
        let items = ["None", "High to Low", "Low to High"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let categoriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Categories"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoriesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 8
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
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
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(currentFilter: FilterOptions) {
        self.viewModel = FilterViewModel(currentFilter: currentFilter)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViews()
        setupActions()
        setupBackgroundTap()
        updateUI()
        
        viewModel.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(priceRangeLabel)
        containerView.addSubview(priceRangeSlider)
        containerView.addSubview(sortingLabel)
        containerView.addSubview(sortingControl)
        containerView.addSubview(categoriesLabel)
        containerView.addSubview(categoriesButton)
        containerView.addSubview(categoriesTableView)
        containerView.addSubview(colorsLabel)
        containerView.addSubview(colorsCollectionView)
        containerView.addSubview(resetButton)
        containerView.addSubview(applyButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 600),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            priceRangeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            priceRangeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            priceRangeSlider.topAnchor.constraint(equalTo: priceRangeLabel.bottomAnchor, constant: 8),
            priceRangeSlider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            priceRangeSlider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            sortingLabel.topAnchor.constraint(equalTo: priceRangeSlider.bottomAnchor, constant: 16),
            sortingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            sortingControl.topAnchor.constraint(equalTo: sortingLabel.bottomAnchor, constant: 8),
            sortingControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            sortingControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            sortingControl.heightAnchor.constraint(equalToConstant: 32),
            
            categoriesLabel.topAnchor.constraint(equalTo: sortingControl.bottomAnchor, constant: 16),
            categoriesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            categoriesButton.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 8),
            categoriesButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            categoriesButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            categoriesButton.heightAnchor.constraint(equalToConstant: 44),
            
            categoriesTableView.topAnchor.constraint(equalTo: categoriesButton.bottomAnchor, constant: 8),
            categoriesTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            categoriesTableView.heightAnchor.constraint(equalToConstant: 120),
            
            colorsLabel.topAnchor.constraint(equalTo: categoriesTableView.bottomAnchor, constant: 16),
            colorsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            colorsCollectionView.topAnchor.constraint(equalTo: colorsLabel.bottomAnchor, constant: 8),
            colorsCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            colorsCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 44),
            
            resetButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 24),
            resetButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            resetButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            resetButton.widthAnchor.constraint(equalToConstant: 80),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            
            applyButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 24),
            applyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            applyButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            applyButton.widthAnchor.constraint(equalToConstant: 120),
            applyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupCollectionViews() {
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        colorsCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        
        priceRangeSlider.value = Float(viewModel.currentPriceRange.max)
    }
    
    private func setupActions() {
        categoriesButton.addTarget(self, action: #selector(categoriesButtonTapped), for: .touchUpInside)
        priceRangeSlider.addTarget(self, action: #selector(priceRangeChanged), for: .valueChanged)
        sortingControl.addTarget(self, action: #selector(sortingChanged), for: .valueChanged)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        containerView.addGestureRecognizer(panGesture)
    }
    
    private func updateUI() {
        categoriesButton.setTitle(viewModel.categoriesButtonTitle, for: .normal)
        priceRangeLabel.text = viewModel.priceRangeText
        priceRangeSlider.value = Float(viewModel.currentPriceRange.max)
        
        switch viewModel.currentSortOption {
        case .none:
            sortingControl.selectedSegmentIndex = 0
        case .priceHighToLow:
            sortingControl.selectedSegmentIndex = 1
        case .priceLowToHigh:
            sortingControl.selectedSegmentIndex = 2
        }
        
        colorsCollectionView.reloadData()
        categoriesTableView.reloadData()
    }
    
    @objc private func categoriesButtonTapped() {
        isCategoriesExpanded.toggle()
    }
    
    @objc private func priceRangeChanged() {
        viewModel.updatePriceRange(priceRangeSlider.value)
    }
    
    @objc private func sortingChanged() {
        switch sortingControl.selectedSegmentIndex {
        case 0:
            viewModel.updateSortOption(.none)
        case 1:
            viewModel.updateSortOption(.priceHighToLow)
        case 2:
            viewModel.updateSortOption(.priceLowToHigh)
        default:
            break
        }
    }
    
    @objc private func resetButtonTapped() {
        viewModel.reset()
        dismiss(animated: true)
    }
    
    @objc private func applyButtonTapped() {
        viewModel.apply()
        dismiss(animated: true)
    }
    
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            let velocity = gesture.velocity(in: view)
            if translation.y > 100 || velocity.y > 500 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.containerView.transform = .identity
                }
            }
        default:
            break
        }
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.availableCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = viewModel.availableCategories[indexPath.row]
        
        cell.textLabel?.text = category.displayName
        cell.accessoryType = viewModel.isCategorySelected(category) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = viewModel.availableCategories[indexPath.row]
        viewModel.toggleCategory(category)
    }
}

extension FilterViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.availableColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        let color = viewModel.availableColors[indexPath.item]
        cell.configure(with: color, isSelected: viewModel.isColorSelected(color))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = viewModel.availableColors[indexPath.item]
        viewModel.toggleColor(color)
    }
}

extension FilterViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        return !containerView.frame.contains(location)
    }
}

extension FilterViewController: FilterViewModelDelegate {
    func filterViewModelDidUpdateFilter() {
        updateUI()
    }
    
    func filterViewModelDidReset() {
        delegate?.filterViewControllerDidReset(self)
    }
    
    func filterViewModelDidApply(_ filter: FilterOptions) {
        delegate?.filterViewController(self, didApplyFilter: filter)
    }
}

class ColorCell: UICollectionViewCell {
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var colorViewConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(colorView)
        updateColorViewConstraints(isSelected: false)
    }
    
    private func updateColorViewConstraints(isSelected: Bool) {
        NSLayoutConstraint.deactivate(colorViewConstraints)
        
        let size: CGFloat = isSelected ? 34 : 30
        
        colorViewConstraints = [
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: size),
            colorView.heightAnchor.constraint(equalToConstant: size)
        ]
        
        NSLayoutConstraint.activate(colorViewConstraints)
    }
    
    func configure(with color: ProductColor, isSelected: Bool) {
        colorView.backgroundColor = color.uiColor
        
        if color == .white {
            colorView.layer.borderWidth = 1
            colorView.layer.borderColor = UIColor.gray.cgColor
        } else {
            colorView.layer.borderWidth = isSelected ? 2 : 0
            colorView.layer.borderColor = isSelected ? UIColor.black.cgColor : UIColor.clear.cgColor
        }
        
        updateColorViewConstraints(isSelected: isSelected)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = nil
        colorView.layer.borderColor = UIColor.clear.cgColor
        colorView.layer.borderWidth = 0
        updateColorViewConstraints(isSelected: false)
    }
} 
