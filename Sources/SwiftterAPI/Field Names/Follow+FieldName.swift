//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/31/25.
//

import Fluent

extension Follow {
    enum FieldName: String, FieldKeyProtocol {
        case id = "id"
        case follower = "follower"
        case following = "following"
        case followedAt = "followed_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}
