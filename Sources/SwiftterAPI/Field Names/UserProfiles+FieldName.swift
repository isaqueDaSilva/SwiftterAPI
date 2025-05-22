//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent

extension UserProfile {
    /// The collections of the field names representation for the ``UserProfile`` table.
    enum FieldName: String, FieldKeyProtocol {
        case slug = "slug"
        case userID = "user_id"
        case profilePictureName = "profile_picture_name"
        case coverImageName = "cover_image_name"
        case bio = "bio"
        case link = "link"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case swifeetCount = "swifeet_count"
        case createdAt = "created_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}
