//
//  HealthKitAssistant.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.08.2021.
//

import Foundation
import HealthKit

class HealthKitSetupAssistant {
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
                
        let healthKitTypesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKQuantityType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        HKHealthStore().requestAuthorization(toShare: [], read: healthKitTypesToRead, completion: { success, error in
            DispatchQueue.main.async(execute: {
                completion(success, error)
            })
        })
    }
}
