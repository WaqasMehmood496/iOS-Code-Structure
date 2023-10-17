//
//  ProfileVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 18.08.2021.
//

import Foundation
import Combine

class ProfileVM {
    
    var repository: ProfileRepositoryProtocol
    var router: ProfileNavigation
    var dataSource = CurrentValueSubject<[ProfileCellContentType], Never>([])
    private var cancellables = Set<AnyCancellable>()
    
    let biometricPublisher = PassthroughSubject<Result<Bool, Error>, Never>()
    
    init(router: ProfileNavigation, repository: ProfileRepositoryProtocol) {
        self.repository = repository
        self.router = router
        self.binding()
    }
    
    private func binding() {
        self.repository.dataSource
            .assign(to: \.value, on: self.dataSource)
            .store(in: &cancellables)
    }
    
    // Navigaiton
    func navigateToSettings() {
        self.router.navigateToSettings()
    }
    
    func navigateToEditProfile() {
        self.router.navigateToProfileEdit()
    }
    
    func navigateToBenefit(type: ProfileSettings) {
        switch type {
        case .advise:
            self.router.navigateToAdvise()
        case .benefits:
            self.router.navigateToBenefits()
            
        }
    }
    
    func syncData() {
        repository.getCarboneOffset()
    }
    
    func navigateToStatistic(type: ProfileStatistic) {
        switch type {
        case .score:
            self.router.navigateToStatistic(statisticType: .wellbeing)
        case .sleep:
            self.router.navigateToStatistic(statisticType: .sleep)
        case .weight:
            self.router.navigateToStatistic(statisticType: .weight)
        case .steps:
            self.router.navigateToStatistic(statisticType: .steps)
        case .impact:
            self.router.navigateToMyImpact()
        }
    }
    
    func navigateToPersonalDevelopment() {
        self.router.navigateToPersonalDevelopment()
    }
    
    func navigateToAchievments() {
        self.router.navigateToAchievments(dailySteps: repository.tempSteps)
    }
    
    func setupBiometric(isOn: Bool) {
        self.repository.setupBiometric(isOn: isOn, publisher: biometricPublisher)
    }
    
    func logOut() {
        self.repository.logout()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(_):
                    self?.router.navigateToSignIn()
                }
            }.store(in: &cancellables)
    }
}
