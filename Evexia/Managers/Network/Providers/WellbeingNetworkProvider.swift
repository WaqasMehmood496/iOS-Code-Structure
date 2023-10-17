//
//  WellbeingNetworkProvider.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 28.08.2021.
//

import Combine
import Foundation

protocol StatisticNetworkProviderProtocol {
    
    func getWeightStatistic(for model: StatsRequestModel) -> AnyPublisher<StatisticResponse, ServerError>
    
    func getWellbeingStatistic(for model: StatsRequestModel) -> AnyPublisher<[StatsResponseModel], ServerError>

}

final class WellbeingNetworkProvider: NetworkProvider, StatisticNetworkProviderProtocol {
    
    func getWeightStatistic(for model: StatsRequestModel) -> AnyPublisher<StatisticResponse, ServerError> {
        return request(.getWeightStatistic(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getWellbeingStatistic(for model: StatsRequestModel) -> AnyPublisher<[StatsResponseModel], ServerError> {
        return request(.getWellbeingStatistic(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
