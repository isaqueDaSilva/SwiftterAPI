//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/1/25.
//

import Fluent
import Vapor

enum FollowService {
    /// Checks at database if the follow relashionship exists.
    /// - Parameters:
    ///   - followerSlug: The slug of the follower profile.
    ///   - followingSlug: The slug of the following profile.
    ///   - database: The database client representation to check the existence of the relashionship.
    /// - Returns: Returns a ``Follow`` representation, if one was found.
    static func checkFollow(
        with followerSlug: String,
        and followingSlug: String,
        at database: any Database
    ) async throws -> Follow? {
        try await Follow
            .query(on: database)
            .with(\.$follower)
            .with(\.$following)
            .group(.or) { group in
                group
                    .filter(\.$follower.$id, .equal, followerSlug)
                    .filter(\.$following.$id, .equal, followerSlug)
            }
            .first()
    }
    
    /// Updates the follow count for each follower and following profile.
    /// - Parameters:
    ///   - follower: The profile of the follower.
    ///   - following: The profile of the following
    ///   - type: The type of update that will be performed.
    ///   - database: The database client representation to performs the operation.
    static func updateFollow(
        for follower: UserProfile,
        and following: UserProfile,
        with type: UpdateType,
        at database: any Database
    ) async throws {
        try await withThrowingTaskGroup { group in
            _ = group.addTaskUnlessCancelled {
                try await follower.updateFollowingCount(with: type, at: database)
            }
            
            _ = group.addTaskUnlessCancelled {
                try await following.updateFollowersCount(with: type, at: database)
            }
            
            guard try await group.next() != nil else {
                group.cancelAll()
                return
            }
        }
    }
}
