//
//  StatisticContentCell.swift
//  Evexia Staging
//
//  Created by Artem Klimov on 17.08.2021.
//

import UIKit
import Combine

class StatisticContentCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var myStatsLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var statsCollectionView: UICollectionView!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var impactLabel: UILabel!
    @IBOutlet weak var impactView: UIView!
    
    var statisticNavigationPublisher = PassthroughSubject<ProfileStatistic, Never>()
    var cancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setupUI()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(impactSelected) )
        impactView.addGestureRecognizer(gesture)
    }
    
    @objc
    func impactSelected(sender: UITapGestureRecognizer) {
        statisticNavigationPublisher.send(.impact(value: ""))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.shadowView.layer.cornerRadius = 16.0
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowOffset = .zero
        self.shadowView.layer.shadowRadius = 8.0
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
    }
    
    lazy private var dataSource = configDataSource()
    
    private func setupUI() {
        self.statsCollectionView.delegate = self
        self.statsCollectionView.dataSource = dataSource
        self.statsCollectionView.register(StatisticCell.nib, forCellWithReuseIdentifier: StatisticCell.identifier)
        let layout = UICollectionViewFlowLayout()
        self.statsCollectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    func configCell(with model: ProfileStatisticCellModel) {
        if let calories = model.calories {
            self.activityDescriptionLabel.text = "The total number of calories you need in order to maintain your current weight are \(calories), " + (UserDefaults.userModel?.firstName ?? "") + "."
        } else {
            self.activityDescriptionLabel.text = "Please ensure you have filled out all of your personal data and switched on your health data to generate your estimated calories."
        }

        self.update(with: model.statistic.dropLast())
        
        if case let .impact(value) = model.statistic.last {
            impactLabel.text = value
        }
        
        self.configLastUpdateLabel(for: model.lastUpdate)
    }
    
    private func configLastUpdateLabel(for timestamp: Double?) {
        let date = Date(timeIntervalSince1970: timestamp ?? Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateString = dateFormatter.string(from: date)
        self.lastUpdateLabel.text = "Last updated: " + dateString
    }
    
    private func update(with data: [ProfileStatistic]) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, ProfileStatistic>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            self?.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
   private func configDataSource() -> UICollectionViewDiffableDataSource<Int, ProfileStatistic> {
        let dataSource = UICollectionViewDiffableDataSource<Int, ProfileStatistic>(
            collectionView: self.statsCollectionView,
            cellProvider: { collectionView, indexPath, model in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatisticCell.identifier, for: indexPath) as! StatisticCell
                cell.configCell(with: model)
                return cell
            }
        )
        return dataSource
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
    }
}

extension StatisticContentCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (statsCollectionView.frame.width - 16.0) / 2.0
        let height = width / 148.0 * 78.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        self.statisticNavigationPublisher.send(model)
    }
}
