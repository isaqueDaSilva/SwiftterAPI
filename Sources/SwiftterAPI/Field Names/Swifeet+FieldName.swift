//
//  FieldName.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/4/25.
//


import Fluent

extension Swifeet {
    enum FieldName: String, FieldKeyProtocol {
        case id = "id"
        case userProfileID = "user_slug"
        case body = "body"
        case imageName = "image_name"
        case answerOf = "answer_of"
        case likesCount = "likes_count"
        case answersCount = "answers_count"
        case createdAt = "created_at"
        case isDeleted = "is_deleted"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}