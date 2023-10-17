//
//  BenefitPostCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 11.09.2021.
//

import UIKit

// MARK: - BenefitPostCell
class BenefitPostCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private lazy var dataSource = configureDataSource()
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Methods
    @discardableResult
    func config(with model: LocalPost) -> BenefitPostCell {
        let url = URL(string: model.author.avatar?.fileUrl ?? "")
        avatarImageView.setImage(url: url)
        titleLabel.text = model.author.title
        subTitleLabel.text = "Benefit".localized()
        update(with: model.attachments)
        
        return self
    }
}

// MARK: - Private Extension
private extension BenefitPostCell {
    func setupUI() {
        setupCornerView()
        setupAvatarImageView()
        setupTitleLabel()
        setupSubTitleLabel()
        setupCollectionView()
    }
    
    func setupCornerView() {
        cornerView.layer.cornerRadius = 16
    }
    
    func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 12
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Betterhelp"
        titleLabel.font = UIFont(name: "NunitoSans-Semibold", size: 16.0)!
        titleLabel.textColor = .gray900
    }
    
    func setupSubTitleLabel() {
        subTitleLabel.text = "3 hours ago"
        subTitleLabel.font = UIFont(name: "NunitoSans-Regular", size: 12.0)!
        subTitleLabel.textColor = .gray500
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        
        collectionView.register(PostImageCell.nib, forCellWithReuseIdentifier: PostImageCell.identifier)
        collectionView.collectionViewLayout = createLayout()
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.945),
            heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension BenefitPostCell: UICollectionViewDelegate {
    
    func update(with data: [Attachments], animated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapShot = NSDiffableDataSourceSnapshot<Int, Attachments>()
            
            snapShot.appendSections([0])
            snapShot.appendItems(data)
            
            self?.dataSource.apply(snapShot, animatingDifferences: animated)
        }
    }
    
    private func configureDataSource() -> UICollectionViewDiffableDataSource<Int, Attachments> {
        
        let dataSource = UICollectionViewDiffableDataSource<Int, Attachments>(
            collectionView: collectionView) { collectionView, indexPath, model in
             let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: PostImageCell.identifier, for: indexPath) as! PostImageCell)
                cell.config(with: model.fileUrl)
                return cell
        }
        
        return dataSource
    }
}
