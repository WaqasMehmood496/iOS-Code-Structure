//
//  AchievmentsVC.swift
//  Evexia
//
//  Created by Oleg Pogosian on 05.01.2022.
//

import UIKit
import Combine

class AchievmentsVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    internal var viewModel: AchievmentsVM!
    private lazy var dataSource = configDataSource()
    private var cancellables = Set<AnyCancellable>()
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    private let seeImpact = PassthroughSubject<Void, Never>()
    
    private var testTopModels = [
        TopAchievmentsModel(type: .steps, count: 10),
        TopAchievmentsModel(type: .daysIn, count: 22),
        TopAchievmentsModel(type: .prescribed, count: 12),
        TopAchievmentsModel(type: .completed, count: 123)]
    
    private var testExploreModels = [
        ExploreAchivmentModel(descriptionText: "Number of badges collected for days where you have completed more than 7000 steps", imageName: "", isActive: false),
        ExploreAchivmentModel(descriptionText: "Completed 20 Daily Tasks", imageName: "activeTwentyAchieve", isActive: false),
        ExploreAchivmentModel(descriptionText: "Completed 50 Daily Tasks", imageName: "activeFiftyAchieve", isActive: false),
        ExploreAchivmentModel(descriptionText: "Completed 100 Daily Tasks", imageName: "activeHundredAchieve", isActive: false),
        ExploreAchivmentModel(descriptionText: "Completed 175 Daily Tasks", imageName: "activeHundredFiftyAchieve", isActive: false),
        ExploreAchivmentModel(descriptionText: "Completed 250 Daily Tasks", imageName: "activeTwoHundredAchieve", isActive: false)]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
        checkIfAlertShownToday()
    }
    
    private func setupUI() {
        setupCollectionView()
        setupNavigationItem()
        collectionView.dropShadow(radius: 8, xOffset: 0, yOffset: 0, shadowOpacity: 1, shadowColor: UIColor.gray400.withAlphaComponent(0.5))
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "Achievements".localized()
    }
    
    private func binding() {
        viewModel.dataSource
            .sink(receiveValue: { [weak self] data in
                self?.update(with: data)
            }).store(in: &cancellables)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = configDataSource()
        collectionView.register(TopAchievmentsCell.nib, forCellWithReuseIdentifier: TopAchievmentsCell.identifier)
        collectionView.register(ExploreAchievmentsCell.nib, forCellWithReuseIdentifier: ExploreAchievmentsCell.identifier)
        collectionView.register(StepsAchievmentCell.nib, forCellWithReuseIdentifier: StepsAchievmentCell.identifier)
        collectionView.register(ImpactCell.nib, forCellWithReuseIdentifier: ImpactCell.identifier)
    }
    
    private func checkIfAlertShownToday() {
        if viewModel.isNeedShowStepsAchiv {
            if let lastAlertDate = UserDefaults.dateShowingWalkingStepsAchive {
                if Calendar.current.isDateInToday(lastAlertDate) {
                    print("Alert was shown today!")
                } else {
                    showAchievements(type: .walkingSteps)
                }
            } else {
                showAchievements(type: .walkingSteps)
            }
        }
    }
    
    private func showAchievements(type: AchievementViewType) {
        showAchievementPopUp(type: type) { }
        
        switch type {
        case .walkingSteps:
            UserDefaults.dateShowingWalkingStepsAchive = Date()
        default: break
        }
    }
}

extension AchievmentsVC: UICollectionViewDelegate {
    
    func update(with data: [AchievmentsCellContentType], animate: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, AchievmentsCellContentType>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            data.forEach { model in
                switch model {
                case .topAchiev(content: let content):
                    self?.testTopModels = content
                case .exploreAchiev(content: let content):
                    self?.testExploreModels = content
                default:
                    break
                }
            }
            
            self?.dataSource.apply(snapshot, animatingDifferences: animate, completion: { [weak self] in
                self?.collectionView.isHidden = false
            })
        }
    }
    
    func configDataSource() -> UICollectionViewDiffableDataSource<Int, AchievmentsCellContentType> {
        let dataSource = UICollectionViewDiffableDataSource<Int, AchievmentsCellContentType>(
            collectionView: self.collectionView,
            cellProvider: { [unowned self] collectionView, indexPath, model in
                if indexPath.item == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopAchievmentsCell.identifier, for: indexPath) as! TopAchievmentsCell
                    cell.configure(models: self.testTopModels)
                    return cell
                } else if model == .impact {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImpactCell.identifier, for: indexPath) as! ImpactCell
                    cell.seeImpact
                        .sink(receiveValue: { [weak self] in
                            self?.viewModel.navigationToImpact()
                        }).store(in: &cell.cancellables)
                    return cell
                } else if indexPath.item == 2 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StepsAchievmentCell.identifier, for: indexPath) as! StepsAchievmentCell
                    cell.configure(model: testExploreModels[indexPath.row - 2])
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreAchievmentsCell.identifier, for: indexPath) as! ExploreAchievmentsCell
                    cell.configure(model: testExploreModels[indexPath.row - 2])
                    return cell
                }
            })
        return dataSource
    }
}

extension AchievmentsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            return CGSize(width: screenWidth - 30, height: 260)
        case 1:
            return CGSize(width: screenWidth - 30, height: 224)
        case 2:
            return CGSize(width: screenWidth - 30, height: 133)
        default:
            return CGSize(width: (screenWidth - 48) / 2, height: 200)
        }
    }
}
