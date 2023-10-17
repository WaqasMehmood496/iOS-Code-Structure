//
//  OnboardingViewController.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.07.2021.
//

import Combine
import UIKit

final class OnboardingVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var pagerCollectionView: UICollectionView!
    @IBOutlet private weak var pageControll: UIPageControl!
    private var projectsData: [Project] = []
    // MARK: - Properties
    var viewModel: OnboardingVMType!
    private var lastContentOffset: CGFloat = 0.0
    private var currentPage = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.automaticallyAdjustsScrollViewInsets = false
        setupUI()
        let _  = viewModel.getProjects()
            .sink(receiveCompletion: { _ in
                print("complete")
            }, receiveValue: {[weak self] value in
                print("----------------------------------------------------------")
                print("in onboarding vC: \(value.data)")
                self!.projectsData = value.data
            })
    }
}

// MARK: - Private Methods
private extension OnboardingVC {
    
    func setupUI() {
        setupCollectionView()
        setupPage(at: currentPage)
    }
    
    func setupCollectionView() {
        pagerCollectionView.delegate = self
        pagerCollectionView.dataSource = self
        pagerCollectionView.allowsSelection = false
        pagerCollectionView.register(UINib(nibName: OnboardingCell.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCell.identifier)
        pagerCollectionView.register(UINib(nibName: OnboardingCell2.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCell2.identifier)
        pagerCollectionView.register(UINib(nibName: OnboardingCell3.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCell3.identifier)
        pagerCollectionView.register(UINib(nibName: OnboardingCell4.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCell4.identifier)
        pagerCollectionView.register(UINib(nibName: OnboardingCell5.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCell5.identifier)
        pagerCollectionView.register(UINib(nibName: OnboardingCell6.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCell6.identifier)
    }
    
    func showNextItem() {
        let currentItem = pagerCollectionView.indexPathsForVisibleItems[0]
        if currentItem.item == Onboarding.allCases.count - 1 {
            viewModel.navigateToPersonalPlan(profileFlow: .onboarding)
        } else {
            let nextItem = IndexPath(item: currentItem.item + 1, section: currentItem.section)
            pagerCollectionView.scrollToItem(at: nextItem, at: .centeredHorizontally, animated: true)
            setupPage(at: currentItem.item + 1)
        }
        currentPage += 1
        
    }
    
    func showPreviousItem() {
        let currentItem = pagerCollectionView.indexPathsForVisibleItems[0]
        let previousItem = IndexPath(item: currentItem.item - 1, section: currentItem.section)
        pagerCollectionView.scrollToItem(at: previousItem, at: .centeredHorizontally, animated: true)
        setupPage(at: currentItem.item - 1)
        currentPage -= 1
    }
    
    func setupPage(at index: Int) {
        pageControll.layer.cornerRadius = pageControll.frame.height / 2
        previousButton.isHidden = index == 0
        pageControll.currentPage = index
    }
}

// MARK: - CollectionView Delegate
extension OnboardingVC: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.lastContentOffset = scrollView.contentOffset.x
//        scrollView.isUserInteractionEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            pageControll.currentPage = Int(pageNumber)
        self.currentPage = Int(pageNumber)
        self.setupPage(at: self.currentPage)
//        scrollView.isUserInteractionEnabled = true
    }
}

// MARK: - CollectionView Data Source
extension OnboardingVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Onboarding.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return createCell(collectionView, indexPath: indexPath)
    }
}

// MARK: - CollectionView Delegate Flow Layout
extension OnboardingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - IBActions
extension OnboardingVC {
    
//    @IBAction func nextPageButtonDidTap(_ sender: Any) {
//        showNextItem()
//    }
    
    @IBAction func previousPageButtonDidTap(_ sender: Any) {
        showPreviousItem()
    }
    
    @IBAction func skipButtonDidTap(_ sender: Any) {
        viewModel.navigateToPersonalPlan(profileFlow: .onboarding)
    }
}


//MARK: - Create Cells
extension OnboardingVC{
    func createCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.identifier, for: indexPath) as? OnboardingCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: Onboarding.allCases[indexPath.item])
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell2.identifier, for: indexPath) as? OnboardingCell2 else {
                return UICollectionViewCell()
            }
            cell.configure(with: Onboarding.allCases[indexPath.item])
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell3.identifier, for: indexPath) as? OnboardingCell3 else {
                return UICollectionViewCell()
            }
            cell.configure(with: Onboarding.allCases[indexPath.item])
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell4.identifier, for: indexPath) as? OnboardingCell4 else {
                return UICollectionViewCell()
            }
            cell.configure(with: Onboarding.allCases[indexPath.item])
            return cell
        case 4:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell5.identifier, for: indexPath) as? OnboardingCell5 else {
                return UICollectionViewCell()
            }
            cell.configure(with: Onboarding.allCases[indexPath.item], projectsData: projectsData)
            cell.delegate = self
            return cell
        case 5:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell6.identifier, for: indexPath) as? OnboardingCell6 else {
                return UICollectionViewCell()
            }
            cell.configure(with: Onboarding.allCases[indexPath.item])
            cell.delegate = self
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.identifier, for: indexPath) as? OnboardingCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: Onboarding.allCases[indexPath.item])
            return cell
        }
    }
}

protocol OnboardingCell5Delegate{
    func rowSelectInTableView(project:Project)
}
protocol OnboardingCell6Delegate{
    func navigateToHome()
    func navigateToPersonalPlan()
}

extension OnboardingVC:OnboardingCell5Delegate{
    func rowSelectInTableView(project:Project){
        self.setupPage(at: self.currentPage+1)
        showNextItem()
    }
}

extension OnboardingVC:OnboardingCell6Delegate{
    func navigateToHome(){
        viewModel.navigateToHome()
    }
    func navigateToPersonalPlan(){
        viewModel.navigateToPersonalPlan(profileFlow: .onboarding)
    }
}
