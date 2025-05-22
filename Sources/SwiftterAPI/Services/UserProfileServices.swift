//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent
import Vapor

enum UserProfileServices {
    /// Creates a new profile for an user.
    /// - Parameters:
    ///   - userSlug: A slug value for add as identifier at the profile of the user.
    ///   - userID: The id of the user to create a relationship between the profile and user.
    ///   - database: The database client representation to mediates the communication between the API and the Database system.
    /// - Returns: Returns an instance of the created user profile.
    static func create(with userSlug: String, userID: UUID, at database: any Database) async throws -> UserProfile {
        let newProfile = UserProfile(id: userSlug, userID: userID)
        try await newProfile.create(on: database)
        
        return newProfile
    }
}
