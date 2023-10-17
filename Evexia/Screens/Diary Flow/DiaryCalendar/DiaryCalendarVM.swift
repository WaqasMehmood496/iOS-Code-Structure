//
//  DiaryCalendarVM.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation
import Combine

class DiaryCalendarVM {
    
    internal var dataSource = CurrentValueSubject<[DayTasksResponseModel], Never>([])
    internal var errorPublisher = PassthroughSubject<ServerError, Never>()
    internal var selectedDate: CurrentValueSubject<Date, Never>
    
    private var router: DiaryCalendarRouter
    private var repository: DiaryCalnedarRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(router: DiaryCalendarRouter, repository: DiaryCalnedarRepositoryProtocol, selectedDate: CurrentValueSubject<Date, Never>) {
        self.selectedDate = selectedDate
        self.router = router
        self.repository = repository
            
        self.binding()
    }
    
    private func binding() {
        
        self.repository.dataSource
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.errorPublisher.send(error)
                case .finished:
                    return
                }
            }, receiveValue: { [weak self] models in
                self?.dataSource.send(models)
            }).store(in: &self.cancellables)
    }
    
}
