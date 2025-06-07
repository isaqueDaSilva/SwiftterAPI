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
        
        tokenProtectedRoute.get(.parameter(self.slugParameterKey)) { try await self.getProfile(with: $0) }
        
        tokenProtectedRoute.get("search", .parameter(self.slugParameterKey)) { try await self.searchProfile(with: $0) }
        
        tokenProtectedRoute.get("followers", .parameter(self.slugParameterKey)) {
            try await self.getFollow(with: $0, and: .follower)
        }
        
        tokenProtectedRoute.get("following", .parameter(self.slugParameterKey)) {
            try await self.getFollow(with: $0, and: .following)
        }
        
        tokenProtectedRoute.get("profile-picture") { try await self.getPicture(with: $0, and: .profile) }
        
        tokenProtectedRoute.get("cover-picture") { try await self.getPicture(with: $0, and: .cover) }
        
        tokenProtectedRoute.get("swifeets", .parameter(self.slugParameterKey)) {
            try await self.getSwifeets(with: $0, withAnswer: false)
        }
        
        tokenProtectedRoute.get("replies", .parameter(self.slugParameterKey)) {
            try await self.getSwifeets(with: $0, withAnswer: true)
        }
        
        tokenProtectedRoute.patch("update") { try await self.updateProfile(with: $0) }
        
        tokenProtectedRoute.on(.PATCH, "update", "profile-picture", body: .collect(maxSize: "1mb")) {
            try await self.updateImage(with: $0, and: .profile)
        }
        
        tokenProtectedRoute.on(.PATCH, "update", "cover-image", body: .collect(maxSize: "1mb")) {
            try await self.updateImage(with: $0, and: .cover)
        }
        
        tokenProtectedRoute.delete("delete", "profile-picture") { try await self.deleteImage(with: $0, and: .profile) }
        
        tokenProtectedRoute.delete("delete", "cover-picture") { try await self.deleteImage(with: $0, and: .cover) }
    }
    
    @Sendable
    private func getProfile(with request: Request) async throws -> Profile {
        guard request.auth.has(Payload.self) else { throw Abort(.unauthorized) }
        
        let profileSlug = try request.parameters.require(self.slugParameterKey)
        
        return try await UserProfileService.getProfile(by: profileSlug, on: request.db).toDTO()
    }
    
    @Sendable
    private func searchProfile(with request: Request) async throws -> Page<ProfilePreview> {
        guard request.auth.has(Payload.self) else { throw Abort(.unauthorized) }
        
        let profileSlug = try request.parameters.require(self.slugParameterKey)
        
        return try await UserProfileService.getPossibleProfile(by: profileSlug, request: request)
    }
    
    @Sendable
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
    
    @Sendable
    private func updateProfile(with request: Request) async throws -> Profile {
        let payload = try request.auth.require(Payload.self)
        let updateProfileDTO = try request.content.decode(UpdateProfile.self)
        
        try UpdateProfile.validate(content: request)
        
        let profile = try await UserProfileService.getProfile(by: payload.userSlug, on: request.db)
        let updatedProfile = try await profile.updateFields(with: updateProfileDTO, at: request.db)
        
        return try updatedProfile.toDTO()
    }
    
    @Sendable
    private func updateImage(with request: Request, and type: UserProfile.PictureField) async throws -> String {
        let payload = try request.auth.require(Payload.self)
        let pictureData = try request.content.decode(Picture.self).data
        let profile = try await UserProfileService.getProfile(by: payload.userSlug, on: request.db)
        
        let pictureName: String = switch type {
        case .profile:
            profile.profilePictureName
        case .cover:
            profile.coverImageName
        }
        
        switch pictureName {
        case UserProfile.defaultImageName:
            let pictureName = payload.userSlug + "-" + Date().ISO8601Format() + "-" + "\(Int.random(in: .min ... .max))"
            
            let fullPath: String = switch type {
            case .profile:
                try EnvironmentValues.swifeetPicturePath(with: pictureName)
            case .cover:
                try EnvironmentValues.swifeetPicturePath(with: pictureName)
            }
            
            try await FileSystemHandler.write(.init(data: pictureData), at: fullPath)
            try await profile.updatePicturesName(with: pictureName, for: type, at: request.db)
            
            return pictureName
        default:
            let fullPath: String = switch type {
            case .profile:
                try EnvironmentValues.swifeetPicturePath(with: pictureName)
            case .cover:
                try EnvironmentValues.swifeetPicturePath(with: pictureName)
            }
            
            try await FileSystemHandler.write(.init(data: pictureData), at: fullPath)
            try await profile.updatePicturesName(with: pictureName, for: type, at: request.db)
            
            return pictureName
        }
    }
    
    @Sendable
    private func getPicture(with request: Request, and type: UserProfile.PictureField) async throws -> Picture {
        let payload = try request.auth.require(Payload.self)
        let profile = try await UserProfileService.getProfile(by: payload.userSlug, on: request.db)
        
        let pictureName: String = switch type {
        case .profile:
            profile.profilePictureName
        case .cover:
            profile.coverImageName
        }
        
        let fullPath: String = switch type {
        case .profile:
            try EnvironmentValues.swifeetPicturePath(with: pictureName)
        case .cover:
            try EnvironmentValues.swifeetPicturePath(with: pictureName)
        }
        
        let buffer = try await FileSystemHandler.retrive(at: fullPath)
        
        return .init(data: .init(buffer: buffer))
    }
    
    @Sendable
    private func deleteImage(with request: Request, and type: UserProfile.PictureField) async throws -> HTTPStatus {
        let payload = try request.auth.require(Payload.self)
        let profile = try await UserProfileService.getProfile(by: payload.userSlug, on: request.db)
        
        let pictureName: String = switch type {
        case .profile:
            profile.profilePictureName
        case .cover:
            profile.coverImageName
        }
        
        let fullPath: String = switch type {
        case .profile:
            try EnvironmentValues.swifeetPicturePath(with: pictureName)
        case .cover:
            try EnvironmentValues.swifeetPicturePath(with: pictureName)
        }
        
        guard try await FileSystemHandler.delete(at: fullPath) else {
            throw Abort(.badRequest, reason: "Failed to delete the image.")
        }
        
        try await profile.updatePicturesName(with: UserProfile.defaultImageName, for: type, at: request.db)
        
        return .ok
    }
    
    @Sendable
    private func getSwifeets(with request: Request, withAnswer: Bool) async throws -> Page<ReadSwifeet> {
        guard request.auth.has(Payload.self) else { throw Abort(.unauthorized) }
        
        let profileSlug = try request.parameters.require(self.slugParameterKey)
        
        let swifeetsQuery = Swifeet.query(on: request.db).with(\.$profile)
        
        let swifeets: Page<Swifeet> = switch withAnswer {
        case true:
            try await swifeetsQuery
                .filter(\.$profile.$id, .equal, profileSlug)
                .paginate(for: request)
        case false:
            try await swifeetsQuery
                .group(.and) { group in
                    group
                        .filter(\.$answerOf, .equal, nil)
                        .filter(\.$profile.$id, .equal, profileSlug)
                }
                .paginate(for: request)
            
        }
        
        return try Page(items: swifeets.items.toDTOCollection(), metadata: swifeets.metadata)
    }
}

extension ProfileController {
    private enum FollowType {
        case follower, following
    }
}
