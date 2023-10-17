//
//  LibraryVC.swift
//  Evexia
//
//  Created by admin on 24.09.2021.
//

import Foundation
import UIKit
import Segmentio
import Combine
import AVFoundation
import Kingfisher
import CRRefresh

class LibraryVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var videoTitleLabel: UILabel!
    @IBOutlet private weak var videoDurationBackgroundVIew: UIStackView!
    @IBOutlet private weak var videoPreviewView: UIImageView!
    @IBOutlet private weak var videoAuthorLabel: UILabel!
    @IBOutlet private weak var videoDurationLabel: UILabel!
    @IBOutlet private weak var typesStackView: UIStackView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var contentTypeCelector: Segmentio!
    @IBOutlet private weak var contentbackgroundView: UIView!
    @IBOutlet private weak var videoBackgroundView: UIView!
    @IBOutlet private weak var contentTableView: UITableView!
    @IBOutlet private weak var favouritesButton: UIButton!
    @IBOutlet private weak var recommendedStackView: UIStackView!
    @IBOutlet weak var configFavoriteView: UIView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var mainVideoFavoriteButton: UIButton!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var allRecommendedButton: UIButton!
    @IBOutlet weak var myFavouritesButton: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    @IBAction func mainVideoFavoriteButtonDidTap(_ sender: UIButton) {
        self.viewModel.changeMainVideoFavorite()
    }
    
    @IBAction func favoriteButtonDidTap(_ sender: UIButton) {
        if UserDefaults.needShowLibraryTutorial {
            UserDefaults.needShowLibraryTutorial = false
            UserDefaults.currentTutorial = nil
            scrollView.isScrollEnabled = true
            (self.tabBarController as? TabBarController)?.customTabBar.isUserInteractionEnabled = true
        }
        self.shadowView.isHidden.toggle()
        favouritesButton.tintColor = self.shadowView.isHidden ? .gray600 : .orange
        scrollView.isScrollEnabled = true
    }
    
    @IBAction func allRecommendedButtonDidTap(_ sender: Any) {
        self.setRecommended()
    }
    
    @IBAction func myFavoriteButtonDidTap(_ sender: Any) {
        self.setFavorites()
    }
    
    // MARK: - Properties
    internal var viewModel: LibraryVM!
    private lazy var overlayTutorial: OverlayTutorialController? = {
        OverlayTutorialController()
        
    }()
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = configDataSource()
    private lazy var categoryDataSource = configureCategoryDataSource()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.binding()
        self.navigationItem.title = "Library".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: true)
        checkTutorialStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shadowView.isHidden = true
        (self.tabBarController as? TabBarController)?.customTabBar.isUserInteractionEnabled = true
    }
    
    private func checkTutorialStatus() {
        guard UserDefaults.needShowLibraryTutorial else { return }
        (self.tabBarController as? TabBarController)?.customTabBar.isUserInteractionEnabled = false
        scrollView.isScrollEnabled = false
        UserDefaults.$currentTutorial
            .sink(receiveValue: { tutarial in
                guard tutarial == .start else { return }
                (self.tabBarController as? TabBarController)?.customTabBar.isUserInteractionEnabled = true
            }).store(in: &cancellables)
    }
}

// MARK: - Private Methods
private extension LibraryVC {
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.shadowView.isHidden = true
        self.favouritesButton.tintColor = self.shadowView.isHidden ? .gray600 : .orange
    }
    
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
        self.videoBackgroundView.addGestureRecognizer(tap)
        self.setupSegmentedControll()
        self.setupContentTable()
        self.setupViews()
        self.configcategoryCollection()
        self.setupScrollView()
        self.setupFavoriteView()
    }
    
    func binding() {
        self.viewModel.bindOnCategorise()
        
        self.viewModel.isOnFavoriteFilter
            .sink(receiveValue: { [weak self] isOn in
                self?.contentTitleLabel.text = isOn ? "My Favourites" : "Recommended for you"
                self?.favouritesButton.tintColor = isOn ? .orange : .gray600
                self?.contentTitleLabel.fadeTransition(0.2)
            }).store(in: &cancellables)
        
        self.viewModel.content
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] content in
                self?.scrollView.cr.endHeaderRefresh()
                self?.update(with: content)
            }).store(in: &self.cancellables)
        
        self.viewModel.mainVideoModel
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] model in
                guard let model = model else {
                    self?.videoBackgroundView.isHidden = true
                    self?.videoBackgroundView.fadeTransition(0.2)
                    return
                }
                self?.videoBackgroundView.isHidden = false
                self?.videoBackgroundView.fadeTransition(0.2)
                self?.configVideoView(with: model)
                self?.configStackView(for: model.type)
            }).store(in: &self.cancellables)
        
        self.viewModel.categoryDataSource
            .sink(receiveValue: { [weak self] categories in
                guard !categories.isEmpty else { return }
                
                self?.setCategory(with: categories)
            }).store(in: &self.cancellables)
    }
    
    func setupViews() {
        self.videoPreviewView.layer.cornerRadius = 8.0
        self.videoDurationBackgroundVIew.layer.cornerRadius = 4.0
    }
    
    private func checkTutorialDisplay() {
        if UserDefaults.needShowLibraryTutorial {
            UserDefaults.currentTutorial = .favorite
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                let frame = self.recommendedStackView.convert(self.favouritesButton.frame, to: self.view)
                self.overlayTutorial?.showInViewController(self, for: frame)
            }
        }
    }
    
    func setRecommended() {
        self.shadowView.isHidden = true
        self.viewModel.isOnFavoriteFilter.send(false)
        self.myFavouritesButton.setImage(nil, for: .normal)
        self.allRecommendedButton.setImage(UIImage(named: "check_favorite"), for: .normal)
        self.favouritesButton.tintColor = self.shadowView.isHidden ? .gray600 : .orange
    }
    
    func setFavorites() {
        self.shadowView.isHidden = true
        self.viewModel.isOnFavoriteFilter.send(true)
        self.allRecommendedButton.setImage(nil, for: .normal)
        self.myFavouritesButton.setImage(UIImage(named: "check_favorite"), for: .normal)
        self.favouritesButton.tintColor = self.shadowView.isHidden ? .gray600 : .orange
    }
    
    func configVideoView(with model: ContentModel) {
        self.setFavoriteButtonImage(model.isFavorite)
        self.videoTitleLabel.text = model.title
        self.videoAuthorLabel.text = model.author.username
        if model.duration.isEmpty {
            self.videoDurationBackgroundVIew.isHidden = true
        } else {
            self.videoDurationBackgroundVIew.isHidden = false
            self.videoDurationLabel.text = model.duration
        }
        self.videoPreviewView.kf.setImage(url: model.placeholder, sizes: videoPreviewView.bounds.size, placeholder: UIImage(named: "play_inactive"), completionHandler: { [weak self] result in
            switch result {
            case let .success(value):
                if value.image.size.height < value.image.size.width {
                    
                    self?.videoPreviewView.contentMode = .scaleAspectFit
                } else {
                    self?.videoPreviewView.contentMode = .scaleAspectFill
                }
            case .failure:
                break
            }
        })
    }
    
    func configcategoryCollection() {
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = categoryDataSource
        self.categoryCollectionView.showsHorizontalScrollIndicator = false
        self.categoryCollectionView.collectionViewLayout = createLayout()
        self.categoryCollectionView.register(CategoryCell.nib, forCellWithReuseIdentifier: CategoryCell.identifier)
    }
    
    func setupScrollView() {
        let animator = NormalHeaderAnimator()
        animator.pullToRefreshDescription = ""
        animator.releaseToRefreshDescription = ""
        animator.loadingDescription = ""
        scrollView.cr.addHeadRefresh(animator: animator) { [weak self] in
            
            self?.viewModel.refreshing.send()
        }
        
    }
    
    func configStackView(for types: [Focus]) {
        
        typesStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        let views = types.map { type -> UIImageView in
            let view = UIImageView()
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
            
            view.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
            let image = UIImage(named: type.image_key)
            view.image = image
            return view
        }
        self.typesStackView.addingArrangedSubviews(views)
    }
    
    func setupContentTable() {
        self.contentTableView.delegate = self
        self.contentTableView.register(MediaContentCell.nib, forCellReuseIdentifier: MediaContentCell.identifier)
        self.contentTableView.register(ReadContentCell.nib, forCellReuseIdentifier: ReadContentCell.identifier)
        self.contentTableView.rowHeight = UITableView.automaticDimension
        self.contentTableView.estimatedRowHeight = 96.0
        self.contentTableView.separatorStyle = .none
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .absolute(40.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(UIScreen.main.bounds.width - 32),
            heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        return layout
    }
    
    private func setFavoriteButtonImage(_ isFavorite: Bool) {
        let imageString = isFavorite ? "favorite" : "unfavorite"
        let image = UIImage(named: imageString)
        mainVideoFavoriteButton.setImage(image, for: .normal)
    }
    
    func setupSegmentedControll() {
        
        let options = SegmentioOptions(
            backgroundColor: .clear,
            segmentPosition: .fixed(maxVisibleItems: 3),
            scrollEnabled: false,
            indicatorOptions: SegmentioIndicatorOptions(type: .bottom, ratio: 1.0, height: 3.0, color: .orange),
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .bottom, height: 0.0, color: .gray300),
            verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(ratio: 0, color: .clear),
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: (defaultState:
                                SegmentioState(backgroundColor: .clear, titleFont: UIFont(name: "NunitoSans-Semibold", size: 18.0)!, titleTextColor: .gray900, titleAlpha: 1.0),
                            selectedState: SegmentioState(backgroundColor: .clear, titleFont: UIFont(name: "NunitoSans-Semibold", size: 18.0)!, titleTextColor: .orange, titleAlpha: 1.0),
                            highlightedState: SegmentioState(backgroundColor: .clear, titleFont: UIFont(name: "NunitoSans-Semibold", size: 18.0)!, titleTextColor: .orange, titleAlpha: 1.0))
        )
        
        var content = [SegmentioItem]()
        let whatch = SegmentioItem(title: "Watch".localized(), image: nil)
        let listen = SegmentioItem(title: "Listen".localized(), image: nil)
        let read = SegmentioItem(title: "Read".localized(), image: nil)
        contentTypeCelector.selectedSegmentioIndex = 0
        content = [whatch, listen, read]
        
        self.contentTypeCelector.setup(
            content: content,
            style: .onlyLabel,
            options: options
        )
        
        self.contentTypeCelector.valueDidChange = { [weak self] segmentio, segmentIndex in
            self?.shadowView.isHidden = true
            let title = segmentio.segmentioItems[segmentIndex].title?.uppercased() ?? ""
            guard let filter = ContentType(rawValue: title) else { return }
            
            self?.viewModel.contentType.send(filter)
        }
    }
    
    func setCategory(with conten: [Focus]) {
        
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, Focus>()
            
            snapshot.appendSections([0])
            snapshot.appendItems(conten)
            self?.categoryDataSource.apply(snapshot, animatingDifferences: false)
            
            self?.categoryCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .bottom)
            
        }
        
    }
    
    func update(with conten: [ContentModel]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, ContentModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(conten)
        
        if #available(iOS 15.0, *) {
            self.dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
        self.emptyView.isHidden = dataSource.snapshot().numberOfItems != 0
        
        self.contentTableView.isHidden = dataSource.snapshot().numberOfItems == 0
        
        if !conten.isEmpty {
            checkTutorialDisplay()
        }
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, ContentModel> {
        let dataSource = UITableViewDiffableDataSource<Int, ContentModel>(
            tableView: self.contentTableView,
            cellProvider: { tableView, indexPath, model in
                switch model.fileType {
                case .audio, .video:
                    let cell = tableView.dequeueReusableCell(withIdentifier: MediaContentCell.identifier, for: indexPath) as! MediaContentCell
                    cell.configCell(with: model)
                    cell.changeFavoritePublisher
                        .sink(receiveValue: { [weak self] model in
                        self?.viewModel.changeFavorite(for: model)
                        Vibration.selection.vibrate()
                    }).store(in: &cell.cancellables)
                    return cell
                case .pdf:
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReadContentCell.identifier, for: indexPath) as! ReadContentCell
                    cell.configCell(with: model)
                    cell.changeFavoritePublisher
                        .sink(receiveValue: { [weak self] model in
                        self?.viewModel.changeFavorite(for: model)
                        Vibration.selection.vibrate()
                    }).store(in: &cell.cancellables)
                    
                    return cell
                }
            }
        )
        
        return dataSource
    }
    
    func configureCategoryDataSource() -> UICollectionViewDiffableDataSource<Int, Focus> {
        let dataSource = UICollectionViewDiffableDataSource<Int, Focus>(collectionView: categoryCollectionView) { collectionView, indexPath, model in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
            cell.configCell(with: model)
            return cell
        }
        return dataSource
    }
    private func setupFavoriteView() {
        shadowView.layer.cornerRadius = 8.0
        configFavoriteView.layer.cornerRadius = 8.0
        configFavoriteView.clipsToBounds = true
    }
}

// MARK: - IBActions
private extension LibraryVC {
    @IBAction func playButtonDidTap(_ sender: Any) {
        guard let model = self.viewModel.mainVideoModel.value else { return }
        self.viewModel.showVideo(model)
    }
}

// MARK: - UITableViewDelegate
extension LibraryVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let model = dataSource.itemIdentifier(for: indexPath) else { return }
        
        self.viewModel.applyNavigation(for: model)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfItems = self.viewModel.content.value.count
        if indexPath.row >= (numberOfItems - 2), numberOfItems != 0 {
            self.viewModel.getMoreContent()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension LibraryVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.categoryDataSource.itemIdentifier(for: indexPath) else { return }
        self.setRecommended()
        self.viewModel.category.send(model)
        self.contentTypeCelector.selectedSegmentioIndex = 0
    }
    
}
