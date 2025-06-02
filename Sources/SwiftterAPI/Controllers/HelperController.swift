//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

struct HelperController: RouteCollection, ProtectedRouteProtocol {
    private let slugParameterKey = "slug"
    
    func boot(routes: any RoutesBuilder) throws {
        let tokenProtectedRoute = self.tokenProtectedRoute(with: routes)
        
        routes.get("public-key") { _ in try await CryptographyHandler.generatesPublicKey() }
        
        tokenProtectedRoute.patch("follow", .parameter(self.slugParameterKey)) { try await self.follow(with: $0) }
    }
    
    @Sendable
    private func follow(with request: Request) async throws -> HTTPStatus {
        let payload = try request.auth.require(Payload.self)
        let followingUserSlug = try request.parameters.require(self.slugParameterKey)
        
        try await request.db.transaction { database in
            if let follow = try await FollowService.checkFollow(
                with: payload.userSlug,
                and: followingUserSlug,
                at: database
            ) {
                try await follow.delete(on: database)
                
                try await FollowService.updateFollow(for: follow.follower, and: follow.following, with: .decrement, at: database)
            } else {
                async let followerProfile = try UserProfileService.getProfile(by: payload.userSlug, on: database)
                async let followingProfile = try UserProfileService.getProfile(by: followingUserSlug, on: database)
                
                let profiles = try await [followerProfile, followingProfile]
                
                try await Follow(follower: payload.userSlug, following: followingUserSlug).create(on: database)
                
                try await FollowService.updateFollow(for: followerProfile, and: followingProfile, with: .increment, at: database)
            }
        }
        
        return .ok
    }
}
