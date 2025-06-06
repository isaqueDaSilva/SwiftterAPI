//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent

extension Like {
    enum FieldName: String, FieldKeyProtocol {
        case id = "id"
        case profileSlug = "profile_slug"
        case swifeetID = "swifeet_id"
        case likedAt = "liked_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}
