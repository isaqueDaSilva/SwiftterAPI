//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/1/25.
//

import Fluent
import Vapor

struct ProfileController: RouteCollection, ProtectedRouteProtocol {
    private let slugParameterKey = "slug"
    
    func boot(routes: any RoutesBuilder) throws {
        let profileRoute = routes.grouped("profile")
        let tokenProtectedRoute = self.tokenProtectedRoute(with: profileRoute)
        
        tokenProtectedRoute.get("profile", .parameter(self.slugParameterKey)) { try await self.getProfile(with: $0) }
        
        tokenProtectedRoute.get("search", .parameter(self.slugParameterKey)) { try await self.searchProfile(with: $0) }
        
        tokenProtectedRoute.get("followers", .parameter(self.slugParameterKey)) {
            try await self.getFollow(with: $0, and: .follower)
        }
        
        tokenProtectedRoute.get("following", .parameter(self.slugParameterKey)) {
            try await self.getFollow(with: $0, and: .following)
        }
    }
    
    private func getProfile(with request: Request) async throws -> Profile {
        guard request.auth.has(Payload.self) else { throw Abort(.unauthorized) }
        
        let profileSlug = try request.parameters.require(self.slugParameterKey)
        
        return try await UserProfileService.getProfile(by: profileSlug, on: request.db).toDTO()
    }
    
    private func searchProfile(with request: Request) async throws -> Page<ProfilePreview> {
        guard request.auth.has(Payload.self) else { throw Abort(.unauthorized) }
        
        let profileSlug = try request.parameters.require(self.slugParameterKey)
        
        return try await UserProfileService.getPossibleProfile(by: profileSlug, request: request)
    }
    
    private func getFollow(with request: Request, and type: FollowType) async throws -> Page<ProfilePreview> {
        guard request.auth.has(Payload.self) else { throw Abort(.unauthorized) }
        
        let profileSlug = try request.parameters.require(self.slugParameterKey)
        
        let profile = try await UserProfileService.getProfile(by: profileSlug, on: request.db)
        
        let follow: Page<UserProfile> = switch type {
        case .follower:
            try await profile.$followers.query(on: request.db).paginate(for: request)
        case .following:
            try await profile.$following.query(on: request.db).paginate(for: request)
        }
        
        return try .init(items: follow.items.toPreview(), metadata: follow.metadata)
    }
}

extension ProfileController {
    private enum FollowType {
        case follower, following
    }
}
