import UIKit

protocol DiscoverSearchViewDelegate: AnyObject {
    func searchViewDidTapBack()
    func searchViewDidTapFilter()
    func searchView(_ searchView: DiscoverSearchView, didUpdateSearchText text: String)
}

class DiscoverSearchView: UIView {
    weak var delegate: DiscoverSearchViewDelegate?
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(backButton)
        addSubview(searchBar)
        addSubview(filterButton)
        
        searchBar.delegate = self
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        updateSearchBarConstraints()
    }
    
    private var searchBarConstraints: [NSLayoutConstraint] = []
    
    private func updateSearchBarConstraints() {
        NSLayoutConstraint.deactivate(searchBarConstraints)
        
        let leadingAnchor = backButton.isHidden ? self.leadingAnchor : backButton.trailingAnchor
        let leadingConstant: CGFloat = backButton.isHidden ? 16 : 8
        let trailingConstant: CGFloat = backButton.isHidden ? -16 : -8
        
        searchBarConstraints = [
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant),
            searchBar.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: trailingConstant),
            searchBar.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: backButton.isHidden ? 44 : 40),
            
            filterButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            filterButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 44),
            filterButton.heightAnchor.constraint(equalToConstant: 44)
        ]
        
        NSLayoutConstraint.activate(searchBarConstraints)
    }
    
    func setBackButtonVisible(_ isVisible: Bool) {
        backButton.isHidden = !isVisible
        updateSearchBarConstraints()
        layoutIfNeeded()
    }
    
    @objc private func backButtonTapped() {
        delegate?.searchViewDidTapBack()
    }
    
    @objc private func filterButtonTapped() {
        delegate?.searchViewDidTapFilter()
    }
}

extension DiscoverSearchView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchView(self, didUpdateSearchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
} 