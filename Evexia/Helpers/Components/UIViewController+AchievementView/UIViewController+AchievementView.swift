//
//  AchievementView.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 05.10.2021.
//

import UIKit
import SwiftEntryKit
import SwiftUI
import Foundation

enum AchievementViewType: Equatable {
    case donePersonalPlanOne
    case donePersonalPlanTwo
    case dontDonePersonalPlan
    case doneFirst
    case saveThePlanet
    case walkingSteps
    case completedDailyTask(DailyTaskTypeAchivment)
    case measurementSystem
    
    var isDailyTaskAchievement: Bool {
        return self != .donePersonalPlanOne &&
        self != .donePersonalPlanTwo &&
        self != .dontDonePersonalPlan &&
        self != .doneFirst &&
        self != .saveThePlanet &&
        self != .measurementSystem
    }
}

struct PopUpModel {
    var image: UIImage = UIImage()
    var title: String = ""
    var description: String = ""
    var actionTitle: String = ""
    var imageSize: CGSize = .zero
}

extension UIViewController {
    func showAchievementPopUp(type: AchievementViewType, verticalOffset: CGFloat = 80, action: @escaping Closure) {
        if let setup = setupMessage(type: type, action: action) {
            switch type {
            case .saveThePlanet:
                SwiftEntryKit.display(entry: SavePlanetView(with: setup), using: setupAttributes())
            case .walkingSteps:
                SwiftEntryKit.display(entry: WalkingStepsView(with: setup), using: setupAttributes())
            case .completedDailyTask:
                SwiftEntryKit.display(entry: CompletingDailyTasksView(with: setup), using: setupAttributes())
            case .measurementSystem:
                SwiftEntryKit.display(entry: MeasurementSystemView(with: setup), using: setupAttributes(verticalOffset: verticalOffset))
            default:
                SwiftEntryKit.display(entry: AchievementView(with: setup), using: setupAttributes())
            }
        }
    }
    
    func dismissEnrtyKitAlert() {
        if SwiftEntryKit.isCurrentlyDisplaying {
            SwiftEntryKit.dismiss()
        }
    }
    
    private func setupAttributes(verticalOffset: CGFloat = 80) -> EKAttributes {
        var attributes = EKAttributes.default
        attributes.positionConstraints.verticalOffset = verticalOffset
        attributes.statusBar = .dark
        attributes.displayDuration = .infinity
        attributes.entryBackground = .clear
        attributes.screenBackground = .color(color: .black.with(alpha: 0.4))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8, offset: .zero))
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0.7, spring: .init(damping: 1, initialVelocity: 8)),
            scale: .init(from: 1.05, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 8))
        )
        
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        
        return attributes
    }
    
    private func setupMessage(type: AchievementViewType, action: @escaping Closure) -> EKPopUpMessage? {
        var popUpModel = PopUpModel()
        
        switch type {
        case .donePersonalPlanOne:
            popUpModel.image = UIImage(named: "image_diary_achievement_one")!
            popUpModel.title = "Wow, congratulations on your incredible achievements!"
            popUpModel.description = "You have completed your personal plan with flying colours. We can’t wait to see you succeed again"
            popUpModel.actionTitle = "Let’s go"
            popUpModel.imageSize = .init(width: 60, height: 60)
        case .donePersonalPlanTwo:
            popUpModel.image = UIImage(named: "image_diary_achievement_one")!
            popUpModel.title = "Brilliant work with your personal plan!"
            popUpModel.description = "It is amazing what you can do with a little help and assistance. Keep striving for just a little bit more"
            popUpModel.actionTitle = "Let’s go"
            popUpModel.imageSize = .init(width: 60, height: 60)
        case .dontDonePersonalPlan:
            popUpModel.image = UIImage(named: "image_diary_achievement_two")!
            popUpModel.title = "Sorry to see your personal plan did not fit with your current lifestyle and challenges."
            popUpModel.description = "Maybe try a little bit less to get out a whole lot more out of yourself"
            popUpModel.actionTitle = "Let’s go"
            popUpModel.imageSize = .init(width: 60, height: 60)
        case .doneFirst:
            popUpModel.image = UIImage(named: "winner")!
            popUpModel.title = "Congrats!"
            popUpModel.description = "You completed your first goal 🎉"
            popUpModel.actionTitle = "Got it"
            popUpModel.imageSize = .init(width: 60, height: 60)
        case .saveThePlanet:
            popUpModel.image = UIImage(named: "image_save_planet")!
            popUpModel.title = "Saving the planet"
            popUpModel.description = "By registering your achievements we will be purchasing carbon credits. Help us create a legacy for future generations and leave earth healthier than we found her"
            popUpModel.actionTitle = "Great!"
            popUpModel.imageSize = .init(width: 120, height: 120)
        case .walkingSteps:
            popUpModel.image = UIImage(named: "image_walking_steps")!
            popUpModel.title = "Wow, congratulations on completing your 7000 steps today"
            popUpModel.description = "You have created an impact that counts for our planet. Keep it going."
            popUpModel.actionTitle = "Get the reward"
            popUpModel.imageSize = .init(width: 232, height: 167)
        case let .completedDailyTask(type):
            popUpModel.image = type.image
            popUpModel.title = "Wow, congratulations on continually completing your daily tasks. You will really notice the difference."
            popUpModel.description = type.subTitle
            popUpModel.actionTitle = "Get the reward"
            popUpModel.imageSize = .init(width: 232, height: 167)
        case .measurementSystem:
            popUpModel.title = "Measurement system"
            popUpModel.description = "Please, select a measurement system:"
        }
        
        let message = configMessage(popUpModel: popUpModel, action: action)
        
        return message
    }
    
    private func configMessage(popUpModel: PopUpModel, action: @escaping Closure) -> EKPopUpMessage {
        
        let titleLabel = EKProperty.LabelContent(text: popUpModel.title, style: .init(font: UIFont(name: "NunitoSans-Bold", size: 18.0)!, color: .init(light: .gray900, dark: .gray900), alignment: .center))
        let descriptionLabel = EKProperty.LabelContent(text: popUpModel.description, style: .init(font: UIFont(name: "NunitoSans-Regular", size: 16.0)!, color: .init(light: .gray700, dark: .gray700), alignment: .center))
        let button = EKProperty.ButtonContent(label: .init(text: popUpModel.actionTitle, style: .init(font: UIFont(name: "NunitoSans-SemiBold", size: 20.0)!, color: .white)), backgroundColor: .init(light: .orange, dark: .orange), highlightedBackgroundColor: .clear)
        let themeImage = EKPopUpMessage.ThemeImage(image: EKProperty.ImageContent(image: popUpModel.image, size: CGSize(width: popUpModel.imageSize.width, height: popUpModel.imageSize.height), contentMode: .scaleAspectFit))
        let message = EKPopUpMessage(themeImage: themeImage, title: titleLabel, description: descriptionLabel, button: button) {
           action()
            SwiftEntryKit.dismiss()
        }
        
        return message
    }
}
