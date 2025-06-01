//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/1/25.
//

import Fluent
import Vapor

struct ProfilePreview: Content {
    let slug: String
    let bio: String?
    let profilePictureName: String
}

extension Array where Element == UserProfile {
    func toPreview() throws -> [ProfilePreview] {
        try self.map {
            try .init(
                slug: $0.requireID(),
                bio: $0.bio,
                profilePictureName: $0.profilePictureName
            )
        }
    }
}
