//
//  NetworkProvider.swift
//  Evexia
//
//  Created by  Artem Klimov on 24.06.2021.
//

import Foundation
import Combine
import Network

class NetworkProvider {
    private let session = URLSession.shared
    private let networkMonitoringService: NetworkMonitoringService
    let lock = NSLock()
    
    init(networkMonitoringService: NetworkMonitoringService) {
        self.networkMonitoringService = networkMonitoringService
    }

    func request<T: Decodable>(_ api: APIService) -> AnyPublisher<T, ServerError> {
        return session.dataTaskPublisher(for: api.request)
            .mapError { _ in
                guard self.networkMonitoringService.isNetworkAvailabel else {
                    return ServerError(errorCode: .networkConnectionError)
                }
                return ServerError(errorCode: .networkError)
            }
            .handleEvents(receiveOutput: {
                print(String(data: $0.data, encoding: .utf8) as Any)
            })
            .flatMap { data, response -> AnyPublisher<T, ServerError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .fail(ServerError(errorCode: .networkError))
                }
                
                if 200 ..< 300 ~= httpResponse.statusCode {
                    return self.parse(data: data, for: T.self)
                } else {
                    if httpResponse.statusCode == 401 {
                        return self.refreshToken(target: api)
                    } else {
                        return self.parseError(data: data, for: T.self)
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func refreshToken<T: Decodable>(target: APIService) -> AnyPublisher<T, ServerError> {
        return session.dataTaskPublisher(for: APIService.refreshToken.request)
            .mapError { _ in ServerError(errorCode: .networkError) }
            .flatMap { data, response -> AnyPublisher<RefreshTokenResponseModel, ServerError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .fail(ServerError(errorCode: .networkError))
                }
                
                guard httpResponse.statusCode != 401 else {
                    NotificationCenter.default.post(name: Notification.Name("Logout"), object: nil, userInfo: nil)
                    return .fail(ServerError(errorCode: .networkError))
                }

                return self.parseRefreshToken(data: data, for: RefreshTokenResponseModel.self)
            }
            .flatMap { parsedModel -> AnyPublisher<T, ServerError> in
                UserDefaults.accessToken = parsedModel.accessToken
                UserDefaults.refreshToken = parsedModel.refreshToken
                
                return self.request(target)
            }.eraseToAnyPublisher()
    }
    
    func parse<T: Decodable>(data: Data, for type: T.Type) -> AnyPublisher<T, ServerError> {
        Log.info(String(data: data, encoding: .utf8) as Any)
        do {
            let response: T = try JSONDecoder().decode(type.self, from: data)
            return .just(response)
        } catch let error {
            let status = String(data: data, encoding: .utf8)
            if status == "OK" || status == "Created" {
                return .just(BaseResponse() as! T)
            } else {
                return self.parseError(data: data, for: T.self)
            }
        }
    }
    
    func parseError<T: Decodable>(data: Data, for type: T.Type) -> AnyPublisher<T, ServerError> {
        do {
            let serverError: ServerError = try JSONDecoder().decode(ServerError.self, from: data)
            
            return .fail(serverError)
        } catch {            
            return .fail(ServerError(errorCode: .jsonParseError))
        }
    }
    
    func parseRefreshToken<T: Decodable>(data: Data, for type: T.Type) -> AnyPublisher<T, ServerError> {
        do {
            let response: T = try JSONDecoder().decode(type.self, from: data)
            return .just(response)
        } catch {
            let status = String(data: data, encoding: .utf8)
            if status == "OK" {
                return .just(BaseResponse() as! T)
            } else {
                return self.parseError(data: data, for: T.self)
            }
        }
    }

}
extension DispatchWorkItem {
    /// Dispatch block asynchronously
    /// - Parameter block: Block

    func publisher<Output, Failure: Error>(_ block: @escaping (Future<Output, Failure>.Promise) -> Void) -> AnyPublisher<Output, Failure> {
        Future<Output, Failure> { promise in
            DispatchQueue.global(qos: .background).async { block(promise) }
        }.eraseToAnyPublisher()
    }
}
