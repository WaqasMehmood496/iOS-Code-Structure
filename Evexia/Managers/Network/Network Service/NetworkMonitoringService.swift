//
//  NetworkMonitoringService.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation
import Network

// MARK: - NetworkMonitoringService
class NetworkMonitoringService {
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue.global()
    var isNetworkAvailabel: Bool = true

    init() {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue.global(qos: .background)
        self.monitor.start(queue: self.queue)
        
        self.startMonitoring()
    }

    func startMonitoring() {
        self.monitor.pathUpdateHandler = { path in
            self.isNetworkAvailabel = path.status == .satisfied
        }
    }

    func stopMonitoring() {
        self.monitor.cancel()
    }
}
