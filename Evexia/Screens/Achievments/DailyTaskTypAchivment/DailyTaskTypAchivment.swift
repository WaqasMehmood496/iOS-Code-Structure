//
//  DailyTaskTypAchivment.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 14.03.2022.
//

import UIKit

class DailyTaskShowPopUp {
    var isComplete20 = false
    var isComplete50 = false
    var isComplete100 = false
    var isComplete150 = false
    var isComplete200 = false
    var isComplete365 = false
    
    init() { }
}

enum DailyTaskTypeAchivment: String {
    case complete20
    case complete50
    case complete100
    case complete150
    case complete200
    case complete365
    
    var image: UIImage {
        switch self {
        case .complete20:
            return UIImage(named: "images_completing_daily_20tasks")!
        case .complete50:
            return UIImage(named: "images_completing_daily_50tasks")!
        case .complete100:
            return UIImage(named: "images_completing_daily_100tasks")!
        case .complete150:
            return UIImage(named: "images_completing_daily_175tasks")!
        case .complete200:
            return UIImage(named: "images_completing_daily_250tasks")!
        case .complete365:
            return UIImage(named: "images_completing_daily_365tasks")!
        }
    }
    
    var subTitle: String {
        switch self {
        case .complete20:
            return "You Completed 20 Daily Tasks".localized()
        case .complete50:
            return "You Completed 50 Daily Tasks".localized()
        case .complete100:
            return "You Completed 100 Daily Tasks".localized()
        case .complete150:
            return "You Completed 150 Daily Tasks".localized()
        case .complete200:
            return "You Completed 200 Daily Tasks".localized()
        case .complete365:
            return "You Completed 365 Daily Tasks".localized()
        }
    }
    
    var isShow: Bool {
        let isShowPopUp = UserDefaults.dailyTaskIsShowPopUp
        
        switch self {
        case .complete20:
            return isShowPopUp.isComplete20
        case .complete50:
            return isShowPopUp.isComplete50
        case .complete100:
            return isShowPopUp.isComplete100
        case .complete150:
            return isShowPopUp.isComplete150
        case .complete200:
            return isShowPopUp.isComplete200
        case .complete365:
            return isShowPopUp.isComplete365
        }
    }
    
    func changeIsShow() {
        let isShowPopUp = UserDefaults.dailyTaskIsShowPopUp
        
        switch self {
        case .complete20:
            isShowPopUp.isComplete20 = true
        case .complete50:
            isShowPopUp.isComplete50 = true
        case .complete100:
            isShowPopUp.isComplete100 = true
        case .complete150:
            isShowPopUp.isComplete150 = true
        case .complete200:
            isShowPopUp.isComplete200 = true
        case .complete365:
            isShowPopUp.isComplete365 = true
        }
    }
}
