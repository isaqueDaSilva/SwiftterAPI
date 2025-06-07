//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import Vapor

enum LikeService {
    static func findLike(with swifeetID: String, profileSlug: String, at database: any Database) async throws -> Like? {
        try await Like
            .query(on: database)
            .with(\.$swifeet)
            .group(.and) { group in
                group
                    .filter(\.$id, .equal, swifeetID)
                    .filter(\.$profile.$id, .equal, profileSlug)
            }
            .first()
    }
}
