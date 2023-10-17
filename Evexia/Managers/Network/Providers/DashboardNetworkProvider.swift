//
//  DashboardNetworkProvider.swift
//  Evexia
//
//  Created by admin on 12.09.2021.
//

import Foundation
import Combine

protocol DashboardNetworkProviderProtocol {
    
    /**
     Receive week and daily goals statistic and availabel surveys
     Should return ProgressResponseModel model with in positive cases. In case of error should return ServerError.
     */
    func getWeekStatistic() -> AnyPublisher<ProgressResponseModel, ServerError>
    
    /**
     Remove  survey from available
     Should return ???  model with in positive cases. In case of error should return ServerError.
     */
    func skipWellbeing() -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Remove  survey from available
     Should return BaseResponse  model with in positive cases. In case of error should return ServerError.
     */
    func skipPulse() -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Receive week and daily goals statistic and availabel surveys
     Should return BaseResponse  model with in positive cases. In case of error should return ServerError.
     */
    func getAllStatistic(model: StatsRequestModel) -> AnyPublisher<[WeelbeingStatisticReponseModel], ServerError>
    
    func getDashboard(model: StatsRequestModel) -> AnyPublisher<DashboardResponseModel, ServerError>
    
    func takeBreak(type: BreaksType) -> AnyPublisher<TakeBreakResponse, ServerError>
    
    func syncSteps(count: Int) -> AnyPublisher<BaseResponse, ServerError>
}

final class DashboardNetworkProvider: NetworkProvider, DashboardNetworkProviderProtocol {
    
    func getWeekStatistic() -> AnyPublisher<ProgressResponseModel, ServerError> {
        return self.request(.getWeekProgress)
            .eraseToAnyPublisher()
    }
    
    func skipWellbeing() -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.skipWellbeing)
            .eraseToAnyPublisher()
    }
    
    func skipPulse() -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.skipPulse)
            .eraseToAnyPublisher()
    }
    
    func getAllStatistic(model: StatsRequestModel) -> AnyPublisher<[WeelbeingStatisticReponseModel], ServerError> {
        return self.request(.getAllProgress(model: model))
            .eraseToAnyPublisher()
    }
    
    func getDashboard(model: StatsRequestModel) -> AnyPublisher<DashboardResponseModel, ServerError> {
        return self.request(.getDashboard(model: model)).eraseToAnyPublisher()
    }
    
    func takeBreak(type: BreaksType) -> AnyPublisher<TakeBreakResponse, ServerError> {
        return self.request(.takeBreak(type: type)).eraseToAnyPublisher()
    }
    
    func syncSteps(count: Int) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.syncSteps(count: count)).eraseToAnyPublisher()
    }
}
