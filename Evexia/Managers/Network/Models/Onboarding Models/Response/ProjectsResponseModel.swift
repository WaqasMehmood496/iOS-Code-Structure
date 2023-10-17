//
//  ProjectsResponseModel.swift
//  Evexia
//
//  Created by Codes Orbit on 12/10/2023.
//

import Foundation

// MARK: - ProjectResponseModel
struct ProjectResponseModel: Decodable {
    let data: [Project]
}

// MARK: - Project
struct Project: Decodable {
    let id: String
    let totalContributionsReceived: Int
    let title, summary, description: String
    let image: Image
    let currency: String
    let amount: Int
    let weightType: String
    let company: String?
    let gas: String
    let createdAt, updatedAt, v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case totalContributionsReceived, title, summary, description, image, currency, amount, weightType, company, gas, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - Image
struct Image: Decodable {
    let id: String
    let isUsed: Bool
    let fileType, title, fileURL: String
    let createdAt, updatedAt, v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isUsed, fileType, title
        case fileURL = "fileUrl"
        case createdAt, updatedAt
        case v = "__v"
    }
}
