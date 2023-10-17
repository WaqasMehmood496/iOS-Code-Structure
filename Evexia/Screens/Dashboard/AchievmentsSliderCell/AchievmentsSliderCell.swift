//
//  AchievmentsSliderCell.swift
//  Evexia
//
//  Created by Oleg Pogosian on 10.01.2022.
//

import UIKit

class AchievmentsSliderCell: UITableViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Properties
    private var cellCount = 0
    private var cellData: [BadgeSliderModel] = []
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    private func setupUI() {
        sliderCollectionView.dataSource = self
        sliderCollectionView.delegate = self
        
        sliderCollectionView.register(SlidesAchievmentCell.nib, forCellWithReuseIdentifier: SlidesAchievmentCell.identifier)
    }
    
    func configurateCell(count: Int, array: [BadgeSliderModel]) {
        cellCount = count
        cellData = array
        pageControl.numberOfPages = array.count
        sliderCollectionView.reloadData()
    }
    
    // MARK: - IBActions
    
}

extension AchievmentsSliderCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SlidesAchievmentCell.identifier, for: indexPath) as! SlidesAchievmentCell
//        cell.configurateCell(isMove: indexPath.item == 0, description: "Description for cell", currentProgress: cellData[indexPath.item])
        cell.configurateCell(model: cellData[indexPath.item])
        return cell
    }
        
}

extension AchievmentsSliderCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = collectionView.indexPathsForVisibleItems.first?.item ?? 0
    }
}

extension AchievmentsSliderCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width - 32, height: 175)
    }
    
}
