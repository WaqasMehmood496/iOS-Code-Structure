//
//  ServerError.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation

// MARK: - ServerError
struct ServerError: Error, Decodable {
    var errorCode: ErrorCode
    
    private enum CodingKeys: String, CodingKey {
        case errorCode = "message"
    }
}

// MARK: - ServerError: Equatable
extension ServerError: Equatable {
    static public func == (lhs: ServerError, rhs: ServerError) -> Bool {
        return lhs.errorCode.rawValue == rhs.errorCode.rawValue
    }
}

// MARK: - ErrorCode
enum ErrorCode: String, Decodable {
    case notVerifyedUser = "This user is not verified. Check your mail"
    case ivalidVerificationToken = "Invalid verification token!"
    case verificationTokenExpired = "The verification link has been expired!"
    case notValidCredentials = "This email or password is not correct!"
    case blockedUser = "This user has been blocked!"
    case notValidEmail = "This email is not valid, try again!"
    case notValidPassword = "The minimum password length is 8 characters!"
    case recoveryTokenInvalid = "This recovery token is invalid"
    case emailAlreadyTaken = "This email address is already taken"
    case emailAlreadyTakenSocial = "This email address is already taken. Try another way to sign in"
    case userAlreadyExist = "This user already exists"
    case companyNotExist = "This company does not exist"
    case serverError = "Request failed with status code 400"
    case emailNotMatch = "The email address doesn’t match any account"
    case differentPassword = "Your new password must be different from previous"
    case jsonParseError
    case networkConnectionError
    case networkError
    case notValidtoken = "Wrong authentication token!"
    case passwordNotMatch = "Old password does not correct"
    case rejectSocialForgotPassword = "Sorry... Please, use your social network to sing-in"
    case emailAlreadyExistsWithAnotherSocialNetwork = "Email already exists. Try to sign in via another social network"
    case noQuestionnaire = "There is no available questionnaire"
    case dissabledPostingAndCommenting = "Your posting/commenting abilities are currently turned off by the admin. Please contact support to get more info"
}
