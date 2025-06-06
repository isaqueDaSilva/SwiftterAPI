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
        case profileSlug = "slug"
        case body = "body"
        case imageName = "image_name"
        case likesCount = "likes_count"
        case answerOf = "answer_of"
        case answersCount = "answers_count"
        case createdAt = "created_at"
       
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}
