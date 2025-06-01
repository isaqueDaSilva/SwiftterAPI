//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent
import Vapor

enum UserProfileService {
    /// Creates a new profile for an user.
    /// - Parameters:
    ///   - userSlug: A slug value for add as identifier at the profile of the user.
    ///   - userID: The id of the user to create a relationship between the profile and user.
    ///   - database: The database client representation to mediates the communication between the API and the Database system.
    /// - Returns: Returns an instance of the created user profile.
    static func create(with userSlug: String, userID: String, at database: any Database) async throws -> UserProfile {
        let newProfile = UserProfile(id: userSlug, userID: userID)
        try await newProfile.create(on: database)
        
        return newProfile
    }
    
    static func getProfile(by slug: String, on database: any Database) async throws -> UserProfile {
        let profile = try await UserProfile.find(slug, on: database)
        
        guard let profile else { throw Abort(.notFound, reason: "Profile doesn't exist.") }
        
        return profile
    }
    
    static func getPossibleProfile(by slug: String, request: Request) async throws -> Page<ProfilePreview> {
        let profiles = try await UserProfile.query(on: request.db).filter(\.$id =~ slug).paginate(for: request)
        
        return try .init(items: profiles.items.toPreview(), metadata: profiles.metadata)
    }
}
