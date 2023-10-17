//
//  DiaryCalnedarRepository.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation
import Combine

// MARK: - DiaryCalnedarRepositoryProtocol
protocol DiaryCalnedarRepositoryProtocol {
    var dataSource: PassthroughSubject<[DayTasksResponseModel], ServerError> { get }
}

// MARK: - DiaryCalnedarRepository

final
class DiaryCalnedarRepository {
    
    internal var dataSource = PassthroughSubject<[DayTasksResponseModel], ServerError>()
    
    private var diaryNetworkProvider: DiaryNetworkProviderProtocol
    private var cancellables = Set<AnyCancellable>()

    init(diaryNetworkProvider: DiaryNetworkProviderProtocol) {
        self.diaryNetworkProvider = diaryNetworkProvider
        
        self.getAllDiaryTasks()
    }
    
    private func getAllDiaryTasks() {
        let retuqestModel = DiaryRequestModel(from: Date().minus(months: 6).timeIntervalSince1970 * 1_000,
                                              to: Date().plus(months: 6).timeIntervalSince1970 * 1_000)
        
        self.diaryNetworkProvider.getDiary(for: retuqestModel)
            .sink(receiveCompletion: { [weak self] error in
                self?.dataSource.send(completion: error)
            }, receiveValue: { [weak self] response in
                guard let diary = response.data.diary else { return }
                self?.dataSource.send(diary)
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - DiaryCalnedarRepository: DiaryCalnedarRepositoryProtocol
extension DiaryCalnedarRepository: DiaryCalnedarRepositoryProtocol {
    
}
