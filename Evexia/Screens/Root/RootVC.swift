//
//  RootVC.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 30.06.2021.
//

import UIKit
import Combine

enum TabBarItemType: Int {
    case profile
    case diary
    case dashboard
    case community
    case library
}

class RootVC: TabBarController, StoryboardIdentifiable {
    
    var viewModel: RootVM!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.setDefaultNavBar()
        self.binding()
    }
    
    override func makeTabBar() -> BaseCardTabBar {
        return CardTabBar()
    }
    
    private func binding() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(showStepAchievement(_:)), name: Notification.Name("showStepAchievement"), object: nil)
        
        self.viewModel.errorPublisher
            .sink(receiveValue: { [weak self] serverError in
                self?.modalAlert(modalStyle: serverError.errorCode)
            }).store(in: &cancellables)
    }
    
    @objc
    func showStepAchievement(_ notification: Notification) {
        if let steps = notification.userInfo?["steps"] as? Int {
            DispatchQueue.main.async { [weak self] in
                self?.showAchievementPopUp(type: .walkingSteps, action: {
                    self?.viewModel.navigateToAchievements(steps: steps)
                })
            }
        }
    }
}
