//
//  DiaryNetworkProvider.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation
import Combine

protocol DiaryNetworkProviderProtocol {
    
    /**
    Get all task for current plan for time in DiaryRequestModel.
    Should return DiaryResponseModel model in positive cases with DiaryTaskModels. In case of error should return ServerError.
    */
    func getDiary(for model: DiaryRequestModel) -> AnyPublisher<DiaryResponseModel, ServerError>
    
    /**
    Get all task for current plan for time in DiaryRequestModel.
    Should return OK  in positive cases with DiaryTaskModels. In case of error should return ServerError.
    */
    func compliteTask(for model: CompliteTaskRequestModel) -> AnyPublisher<CompleteTaskResponseModel, ServerError>
    
    /**
    Get all task for current plan for time in DiaryRequestModel.
    Should return DiaryResponseModel model in positive cases with DiaryTaskModels. In case of error should return ServerError.
    */
    func skipTask(for model: TaskRequestModel) -> AnyPublisher<SkippedTaskResponseModel, ServerError>
    
    /**
    Get all task for current plan for time in DiaryRequestModel.
    Should return DiaryResponseModel model in positive cases with DiaryTaskModels. In case of error should return ServerError.
    */
    func undoTask(for model: TaskRequestModel) -> AnyPublisher<UndoTaskResponseModel, ServerError>
     
    func updateSelectedtasks(with model: UpdateSelectedTaskRequestModel) -> AnyPublisher<TaskResponseModel, ServerError>
}

final class DiaryNetworkProvider: NetworkProvider, DiaryNetworkProviderProtocol {
    
    func getDiary(for model: DiaryRequestModel) -> AnyPublisher<DiaryResponseModel, ServerError> {
        return request(.getDiary(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
     
    func compliteTask(for model: CompliteTaskRequestModel) -> AnyPublisher<CompleteTaskResponseModel, ServerError> {
        return request(.compliteTask(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func skipTask(for model: TaskRequestModel) -> AnyPublisher<SkippedTaskResponseModel, ServerError> {
        return request(.skipTask(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func undoTask(for model: TaskRequestModel) -> AnyPublisher<UndoTaskResponseModel, ServerError> {
        return request(.undoTask(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func updateSelectedtasks(with model: UpdateSelectedTaskRequestModel) -> AnyPublisher<TaskResponseModel, ServerError> {
        return request(.updateTask(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
}
