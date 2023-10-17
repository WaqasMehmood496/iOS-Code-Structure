//
//  NotificationEvents.swift
//  Evexia
//
//  Created by admin on 09.11.2021.
//

import Foundation
enum NotificationServiceEvent: String {
    case dashBoard = "DASHBOARD"
    case diary = "DIARY"
    case wellbeingQuestionare = "WELLBEING"
    case pulseQuestionare = "PULSE"
    case community = "COMMUNITY"
    case achievement = "ACHIEVEMENT"
}

enum NotificationActionType: String {
    case openScreen = "OPEN_SCREEN"
    case openQuestionnaire = "OPEN_QUESTIONNAIRE"
}
