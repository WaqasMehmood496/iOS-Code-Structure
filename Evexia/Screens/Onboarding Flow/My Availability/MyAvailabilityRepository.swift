//
//  MyAvailabilityRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import Foundation
import Combine

protocol MyAvailabilityRepositoryProtocol {
    func setAvailability() -> AnyPublisher<Result<BaseResponse, ServerError>, Never>
    func setDuration(to value: Int?)
    
    var duration: CurrentValueSubject<Int?, Never> { get }
    var isAvailabilitySet: CurrentValueSubject<Bool, Never> { get }
    var dataSource: CurrentValueSubject<[DaySliderCellModel], Never> { get }
}

class MyAvailabilityRepository {
    var isAvailabilitySet = CurrentValueSubject<Bool, Never>(false)
    var dataSource = CurrentValueSubject<[DaySliderCellModel], Never>([])
    var duration = CurrentValueSubject<Int?, Never>(nil)
    
    private var updatedDuration = CurrentValueSubject<Int?, Never>(UserDefaults.userModel?.availability.duration)
    private var networkProvider: OnboardingNetworkProviderProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkProvider: OnboardingNetworkProviderProtocol) {
        self.networkProvider = networkProvider
        self.generateDataSource()
        
        self.binding()
    }
    
    private func binding() {
        self.duration.send(UserDefaults.userModel?.availability.duration)
        
        Publishers.CombineLatest(Publishers.MergeMany(self.dataSource.value.map { $0.value }), self.updatedDuration)
            .sink(receiveValue: { [weak self] _, _ in
                self?.observeAvailabilityChanges()
            }).store(in: &cancellables)
    }
    
    private func generateDataSource() {
        let cal = UserDefaults.userModel?.availability.calendar
        let calendar = cal?.dict.sorted(by: { $0.key < $1.key })
        .map { DaySliderCellModel(value: $0.value, day: $0.key) }
        
        self.dataSource.send(calendar ?? [])
            
    }
    
    private func observeAvailabilityChanges() {
        let isSet = self.dataSource.value.contains(where: { $0.value.value != 0 }) && !self.updatedDuration.value.isNil
        self.isAvailabilitySet.send(isSet)
    }
}

extension MyAvailabilityRepository: MyAvailabilityRepositoryProtocol {
    
    func setAvailability() -> AnyPublisher<Result<BaseResponse, ServerError>, Never> {
        let calendarDict = self.dataSource.value.reduce([String: Int]()) { data, model -> [String: Int] in
            var data = data
            data[model.day.rawValue] = model.value.value
            return data
        }
        
        guard let calendar = AvailabilityCalendar(dictionary: calendarDict) else {
            return .just(.failure(ServerError(errorCode: .jsonParseError)))
        }
        
        let availabilityModel: Availability = Availability(duration: self.updatedDuration.value, calendar: calendar)
        
        if UserDefaults.isOnboardingDone {
            return self.networkProvider.resetPlan(with: availabilityModel)
                .map({ responseModel -> Result<BaseResponse, ServerError> in
                    UserDefaults.userModel?.availability = availabilityModel
                    return .success(responseModel)
                }).catch({ serverError -> AnyPublisher<Result<BaseResponse, ServerError>, Never> in
                    return .just(.failure(serverError))
                }).eraseToAnyPublisher()
        } else {
            return self.networkProvider.setAvailability(with: availabilityModel)
                .map({ responseModel -> Result<BaseResponse, ServerError> in
                    UserDefaults.userModel?.availability = availabilityModel
                    return .success(responseModel)
                }).catch({ serverError -> AnyPublisher<Result<BaseResponse, ServerError>, Never> in
                    return .just(.failure(serverError))
                }).eraseToAnyPublisher()
        }
    }
    
    func setDuration(to value: Int?) {
        self.updatedDuration.value = value
    }
}
