//
//  APIService.swift
//  Evexia
//
//  Created by  Artem Klimov on 24.06.2021.
//

import Foundation

// MARK: - APIService
enum APIService {
    // Authorization
    case signUp(model: UserAuthModel)
    case signIn(model: UserAuthModel)
    case verification(model: VerificationModel)
    case resendVerification(email: String)
    case logout
    case deleteAccount
    case refreshToken
    case lastVisit
    
    // Firebase Cloud Message
    case refreshFCMToken(String)
    
    // Password recovery
    case passwordRecovery(email: String)
    case resetPassword(ResetPasswordModel)
    case changePassword(model: ChangePasswordModel)
    
    // User Profile
    case getUserProfile
    case updateProfile(model: UpdateProfileModel)
    case setAvatar(data: Data)
    case setWeight(weight: UpdateWeightModel)
    case deleteAvatar
    case countries
    case changeAchievementsApearance(isOn: Bool)
    
    // Personal Plan
    case personalPlan(model: PlanRequestModel)
    case getMyWhyList
    case setMyWhy(model: MyWhySendModel)
    case getMyGoalsList
    case setMyGoals(model: MyGoalsSendModel)
    case setAvailability(model: Availability)
    case resetPlan(model: Availability)
    
    // Profile
    case benefits(model: BenefitRequestModel)
    case getWeightStatistic(model: StatsRequestModel)
    case getWellbeingStatistic(model: StatsRequestModel)
    case support
    case incrementBenefitViews(id: String)
    
    // Personal Development
    case getPersonalDevelopmentCategories
    case getPersonalDevelopmentCategory(id: Int, model: BenefitRequestModel)
    case makePDCategoryFavorite(id: String)
    case removePDCategoryFromFavorites(id: String)
    case getFavoritePDCategory(model: BenefitRequestModel)
    
    // Diary
    case getDiary(model: DiaryRequestModel)
    case compliteTask(model: CompliteTaskRequestModel)
    case undoTask(model: TaskRequestModel)
    case skipTask(model: TaskRequestModel)
    case updateTask(model: UpdateSelectedTaskRequestModel)
    
    // Dashboard
    case getWeekProgress
    case getAllProgress(model: StatsRequestModel)
    case skipWellbeing
    case skipPulse
    case getDashboard(model: StatsRequestModel)
    case takeBreak(type: BreaksType)
    case dashboardSteps(model: [LeaderboardSteps])
    case syncSteps(count: Int)
    
    // Community
    case createPost(model: CreatePostRequestModel)
    case createStaticPost(String)
    case getPosts(model: CommunityRequestModel)
    case deletePost(String)
    case editPost(model: CreatePostRequestModel, postId: String)
    case getShares(String)
    case addShares
    case getLikes(String)
    case addRemoveLike(String)
    case uploadImage(data: [Data])
    case uploadVideo(data: Data)
    case createComment(content: String, postId: String, ids: [String])
    case getComments(model: CommunityRequestModel, postId: String)
    case addReply(postId: String, commentId: String, content: String, replyToModel: ReplyToModel, ids: [String])
    case searchUser(name: String)
    case getPost(id: String)
    
    // Questionnaire
    case getPulse
    case getWellbeing
    case completePulse(model: QuestionnaireRequestModel, questionareId: String)
    case completeWellbeing(model: QuestionnaireRequestModel, questionareId: String)
    
    // Library
    case getLibrary(model: LibraryRequestModel)
    case watched(id: String)
    case favorites(id: String)
    case undoFavorites(id: String)
    case getFavorites(model: LibraryRequestModel)
    
    // Achievements
    case getAchiev
    case getCarboneOffset
    case leaderboard(model: [LeaderboardSteps])
    
    //Projects
    case getProjects

}

// MARK: - APIService: APITarget
extension APIService: APITarget {
    
    var baseURL: String {
        return .baseUrl
    }
    
    var path: String {
        switch self {
        case .signUp:
            return "auth/sign-up"
        case .signIn:
            return "auth/sign-in"
        case .verification:
            return "auth/verification"
        case .getUserProfile:
            return "profile"
        case .passwordRecovery:
            return "password/link"
        case .resetPassword:
            return "password/reset"
        case .personalPlan:
            return "profile/personal-plan"
        case .getMyWhyList:
            return "admin/my-why"
        case .setMyWhy:
            return "profile/my-why"
        case .getMyGoalsList:
            return "profile/my-goals"
        case .setMyGoals:
            return "profile/my-goals"
        case .setAvailability:
            return "profile/availability"
        case .resetPlan:
            return "diary/reset-plan"
        case .setAvatar:
            return "profile/avatar"
        case .updateProfile:
            return "profile"
        case .setWeight:
            return "profile/weight"
        case .deleteAvatar:
            return "profile/avatar"
        case .countries:
            return "profile/countries"
        case .logout:
            return "auth/sign-out"
        case .deleteAccount:
            return "profile"
        case .refreshToken:
            return "auth/refresh-token"
        case .lastVisit:
            return "profile/last-visit"
        case .refreshFCMToken:
            return "auth/refresh-fcm"
        case .resendVerification:
            return "auth/resend-verification"
        case .changePassword:
            return "password/change"
        case .benefits:
            return "benefits"
        case .support:
            return "support"
        case .getWeightStatistic:
            return "profile/weight"
        case .getWellbeingStatistic:
            return "profile/wellbeing"
        case .getDiary:
            return "diary"
        case .compliteTask:
            return "diary/task"
        case .undoTask:
            return "diary/undo"
        case .skipTask:
            return "diary/skip-task"
        case .getWeekProgress:
            return "dashboard/week-progress"
        case .getAllProgress:
            return "dashboard/all-progress"
        case .skipWellbeing:
            return "dashboard/skip-wellbeing"
        case .skipPulse:
            return "dashboard/skip-pulse"
        case .getDashboard:
            return "dashboard"
        case .dashboardSteps:
            return "dashboard/steps"
        case .takeBreak:
            return "dashboard/streak-break"
        case .updateTask:
            return "diary"
        case .createPost:
            return "community"
        case .createStaticPost:
            return "community/static"
        case .getPosts:
            return "community"
        case let .deletePost(id):
            return "community/\(id)"
        case let .editPost(_, id):
            return "community/\(id)"
        case let .getShares(id):
            return "community/shares/\(id)"
        case .addShares:
            return "community/shares"
        case let .getLikes(id):
            return "community/likes/\(id)"
        case let .addRemoveLike(id):
            return "community/likes/\(id)"
        case .uploadImage:
            return "attachment/images"
        case .uploadVideo:
            return "attachment/video"
        case let .createComment(_, postId: id, _):
            return "community/comment/\(id)"
        case let .getComments(model: _, postId: id):
            return "community/comment/\(id)"
        case let .addReply(postId: postId, commentId: commentId, content: _, replyToModel: _, _):
            return "community/comment/reply/\(postId)/\(commentId)"
        case .getPulse:
            return "questionnaire/pulse"
        case .getWellbeing:
            return "questionnaire/wellbeing"
        case let .completePulse(_, id):
            return "questionnaire/pulse/" + id
        case let .completeWellbeing(_, id):
            return "questionnaire/wellbeing/" + id
        case .getLibrary:
            return "library"
        case let .watched(id):
            return "library/" + id
        case let .incrementBenefitViews(id):
            return "benefits/" + id
        case let .favorites(id):
            return "library/favorites/" + id
        case let .undoFavorites(id):
           return "library/favorites/" + id
        case .getFavorites:
            return "library/favorites"
        case .getPersonalDevelopmentCategories:
            return "personal-dev"
        case let .getPersonalDevelopmentCategory(id, _):
            return "personal-dev/\(id)"
        case let .makePDCategoryFavorite(id):
            return "personal-dev/favorite/" + id
        case let .removePDCategoryFromFavorites(id):
            return "personal-dev/favorite/" + id
        case .getFavoritePDCategory:
            return "personal-dev/favorite"
        case .getAchiev:
            return "achievements"
        case .changeAchievementsApearance:
            return "profile/achievements-view"
        case .getCarboneOffset:
            return "achievements/carbon-offset"
        case .searchUser:
            return "community/employees"
        case let .getPost(id):
            return "community/post/" + id
        case .syncSteps:
            return "dashboard/notification/"
        case .leaderboard:
           return "admin/analytics/leader-board"
        case .getProjects:
            return "projects"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .signUp:
            return .POST
        case .signIn:
            return .POST
        case .verification:
            return .POST
        case .getUserProfile:
            return .GET
        case .passwordRecovery:
            return .POST
        case .resetPassword:
            return .POST
        case .getMyWhyList:
            return .GET
        case .setMyWhy:
            return .PUT
        case .getMyGoalsList:
            return .GET
        case .setMyGoals:
            return .PUT
        case .setAvailability:
            return .PUT
        case .resetPlan:
            return .POST
        case .setAvatar:
            return .PUT
        case .updateProfile:
            return .PUT
        case .setWeight:
            return .PUT
        case .deleteAvatar:
            return .DELETE
        case .countries:
            return .GET
        case .logout:
            return .POST
        case .deleteAccount:
            return .DELETE
        case .refreshToken:
            return .POST
        case .lastVisit:
            return .POST
        case .refreshFCMToken:
            return .POST
        case .resendVerification:
            return .POST
        case .changePassword:
            return .POST
        case .benefits:
            return .GET
        case .getWeightStatistic:
            return .GET
        case .getWellbeingStatistic:
            return .GET
        case .getDiary:
            return .GET
        case .compliteTask:
            return .PUT
        case .undoTask:
            return .PUT
        case .skipTask:
            return .POST
        case .getWeekProgress:
            return .GET
        case .getAllProgress:
            return .GET
        case .getDashboard:
            return .GET
        case .takeBreak:
            return .PUT
        case .dashboardSteps:
            return .POST
        case .skipWellbeing:
            return .PUT
        case .skipPulse:
            return .PUT
        case .updateTask:
            return .PUT
        case .createPost:
            return .POST
        case .createStaticPost:
            return .POST
        case .getPosts:
            return .GET
        case .deletePost:
            return .DELETE
        case .editPost:
            return .PUT
        case .getShares:
            return .GET
        case .addShares:
            return .PUT
        case .getLikes:
            return .GET
        case .addRemoveLike:
            return .PUT
        case .uploadImage:
            return .POST
        case .uploadVideo:
            return .POST
        case .createComment:
            return .POST
        case .getComments:
            return .GET
        case .addReply:
            return .POST
        case .getPulse:
            return .GET
        case .getWellbeing:
            return .GET
        case .completePulse:
            return .POST
        case .completeWellbeing:
            return .POST
        case .support:
            return .GET
        case .getLibrary:
            return .GET
        case .watched:
            return .PUT
        case .personalPlan:
            return .PUT
        case .incrementBenefitViews:
            return .PUT
        case .favorites:
            return .PUT
        case .undoFavorites:
            return .DELETE
        case .getFavorites:
             return .GET
        case .getPersonalDevelopmentCategories:
            return .GET
        case .getPersonalDevelopmentCategory:
            return .GET
        case .makePDCategoryFavorite:
            return .PUT
        case .removePDCategoryFromFavorites:
            return .DELETE
        case .getFavoritePDCategory:
            return .GET
        case .getAchiev:
            return .GET
        case .changeAchievementsApearance:
            return .PUT
        case .getCarboneOffset:
            return .GET
        case .searchUser:
            return .GET
        case .getPost:
            return .GET
        case .syncSteps:
            return .GET
        case .leaderboard:
            return .POST
        case .getProjects:
            return .GET
        }
    }
    
    var queryParams: [URLQueryItem]? {
        switch self {
        case let .getPosts(model), let .getComments(model: model, postId: _):
            return [URLQueryItem(name: "limit", value: model.limit),
                    URLQueryItem(name: "counter", value: model.counter)
            ]
        case let .getWeightStatistic(model), let .getWellbeingStatistic(model), let .getAllProgress(model), let .getDashboard(model):
            return self.getQueryItems(for: model.dictionary)
        case let .getDiary(model):
            return self.getQueryItems(for: model.dictionary)
        case let .getLibrary(model), let .getFavorites(model):
            return getQueryItems(for: model.dictionary)
        case let .benefits(model):
            return getQueryItems(for: model.dictionary)
        case let .getPersonalDevelopmentCategory(_, model):
            let dict: [String: Any] = ["limit": model.limit, "counter": model.counter]
            return getQueryItems(for: dict)
        case let .getFavoritePDCategory(model):
            let dict: [String: Any] = ["limit": model.limit, "counter": model.counter]
            return getQueryItems(for: dict)
        case let .takeBreak(type):
            let dict = ["type": type.rawValue]
            return getQueryItems(for: dict)
        case let .searchUser(name):
            return [URLQueryItem(name: "username", value: name)]
        case let .syncSteps(count):
            let dict: [String: Any] = ["steps": count]
            return getQueryItems(for: dict)
        default:
            return nil
        }
    }
    
    var bodyParams: Data? {
        switch self {
        case let .signUp(model), let .signIn(model):
            return self.getJsonData(for: model.dictionary)
        case let .verification(model):
            return self.getJsonData(for: model.dictionary)
        case let .passwordRecovery(email):
            return self.getJsonData(for: ["email": email])
        case let .resetPassword(model):
            return self.getJsonData(for: model.dictionary)
        case let .setMyWhy(model):
            return self.getJsonData(for: model.dictionary)
        case let .setMyGoals(model):
            return self.getJsonData(for: model.dictionary)
        case let .setAvailability(model):
            return self.getJsonData(for: model.dictionary)
        case let .resetPlan(model):
            return self.getJsonData(for: model.dictionary)
        case let .updateProfile(model):
            return self.getJsonData(for: model.dictionary)
        case let .setAvatar(imageData):
            return self.getMultipartData(for: imageData)
        case let .setWeight(model):
            return self.getJsonData(for: model.dictionary)
        case .refreshToken:
            return self.getJsonData(for: ["refreshToken": UserDefaults.refreshToken ?? ""])
        case let .refreshFCMToken(token):
            return self.getJsonData(for: ["fbToken": token])
        case let .resendVerification(email):
            return self.getJsonData(for: ["email": email])
        case let .changePassword(model):
            return self.getJsonData(for: model.dictionary)
        case let .compliteTask(model):
            return self.getJsonData(for: model.dictionary)
        case let .undoTask(model):
            return self.getJsonData(for: model.dictionary)
        case let .skipTask(model):
            return self.getJsonData(for: model.dictionary)
        case let .updateTask(model):
            return self.getJsonData(for: model.dictionary)
        case let .createPost(model: model):
            return self.getJsonData(for: model.dictionary)
        case let .editPost(model: model, _):
            return self.getJsonData(for: model.dictionary)
        case let .createStaticPost(step):
            return self.getJsonData(for: ["content": step])
        case let .uploadImage(data: data):
            return self.uploadMedia(imageData: data, videoData: nil, mediaType: .image)
        case let .uploadVideo(data: data):
            return self.uploadMedia(imageData: nil, videoData: data, mediaType: .video)
        case let .createComment(content: content, _, ids):
            return self.getJsonData(for: ["content": content, "employees": ids])
        case let .addReply(postId: _, commentId: _, content: content, replyToModel: model, ids: ids):
            var models: [String: Any] = ["content": content]
            models["replyTo"] = model.dictionary
            models["employees"] = ids
            return self.getJsonData(for: models)
        case let .completePulse(model, _):
            return self.getJsonData(for: model.dictionary)
        case let .completeWellbeing(model, _):
            return self.getJsonData(for: model.dictionary)
        case let .personalPlan(model):
            return self.getJsonData(for: model.dictionary)
        case let .changeAchievementsApearance(isOn):
            return getJsonData(for: ["isShownAchievements": isOn])
        case let .dashboardSteps(model: model):
            let dict: [String: Any] = ["data": model].dictionary
            return getJsonData(for: dict)
        case let .leaderboard(model: model):
            let dict: [String: Any] = ["data": model].dictionary
            return self.getJsonData(for: dict)
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        var headers = [String: String]()
        switch self {
        case .signIn, .getMyWhyList, .getMyGoalsList, .refreshToken:
            headers = ["Content-type": "application/json"]
        case let .uploadImage(data: data):
            headers = ["Content-type": "multipart/form-data; boundary=\(data.hashValue)"]
            
            let token = UserDefaults.accessToken
            headers["Authorization"] = "Bearer \(token ?? "")"
        case let .setAvatar(data), let .uploadVideo(data: data):
            headers = ["Content-type": "multipart/form-data; boundary=\(data.hashValue)"]
            
            let token = UserDefaults.accessToken
            headers["Authorization"] = "Bearer \(token ?? "")"
        default:
            let token = UserDefaults.accessToken
            headers = ["Content-type": "application/json" ]
            headers["Authorization"] = "Bearer \(token ?? "")"
        }
        return headers
    }
    
    var request: URLRequest {
        var components = URLComponents(string: self.baseURL + self.path)!
        components.queryItems = self.queryParams
        var request = URLRequest(url: components.url!)
        
        request.httpBody = self.bodyParams
        request.httpMethod = self.method.rawValue
        print(request)
        
        self.headers?.forEach({ key, value in
            request.setValue(value, forHTTPHeaderField: key)
        })
        return request
    }
    
    private func getJsonData(for dictionary: [String: Any]) -> Data? {
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary)
        return jsonData
    }
    
    private func getQueryItems(for dictionary: [String: Any]) -> [URLQueryItem] {
        return dictionary.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }
    
    private func uploadMedia(imageData: [Data]?, videoData: Data?, mediaType: MediaType) -> Data? {
        
        switch mediaType {
        case .image:
            guard let data = imageData else { return nil }
            let boundary = String(data.hashValue)
            return getMultipartImageData(
                name: "file.jpg",
                filePathKey: "image",
                data: data,
                boundary: boundary,
                mimetype: "image/jpg"
            )
        case .video:
            guard let data = videoData else { return nil }
            let boundary = String(data.hashValue)
            return getMultipartVideoData(
                name: "myVideo.mov",
                filePathKey: "video",
                data: data,
                boundary: boundary,
                mimetype: "video/mov"
            )
        }
    }
    
    private func getMultipartData(for data: Data) -> Data? {
        var tempData = Data()
        tempData.append("\r\n--\(data.hashValue)\r\n".data(using: .utf8)!)
        tempData.append("Content-Disposition: form-data; name=\"image\"; filename=\"file.jpg\"\"\r\n".data(using: .utf8)!)
        tempData.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
        tempData.append(data)
        tempData.append("\r\n--\(data.hashValue)--\r\n".data(using: .utf8)!)
        return tempData
    }
    
    private func getMultipartImageData(name: String, filePathKey: String?, data: [Data], boundary: String, mimetype: String) -> Data? {
        let body = NSMutableData()
        data.enumerated().forEach { index, value in
            body.appendString("--\(boundary)\r\n")
            body.appendString("\(HTTPHeadersKey.contentDisposition.rawValue): form-data; name=\"\(filePathKey!)\"; filename=\"\(index)\(name)\"\r\n")
            body.appendString("\(HTTPHeadersKey.contentType.rawValue): \(mimetype)\r\n\r\n")
            body.append(value)
            body.appendString("\r\n")
            
        }
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    
    private func getMultipartVideoData(name: String, filePathKey: String?, data: Data, boundary: String, mimetype: String) -> Data? {
        let body = NSMutableData()
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("\(HTTPHeadersKey.contentDisposition.rawValue): form-data; name=\"\(filePathKey!)\"; filename=\"\(name)\"\r\n")
        body.appendString("\(HTTPHeadersKey.contentType.rawValue): \(mimetype)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
}
