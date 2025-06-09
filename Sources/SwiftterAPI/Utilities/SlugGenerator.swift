//
//  SlugGenerator.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

enum SlugGenerator {
    /// Generates a slug for an user profile, based on your name.
    /// - Parameters:
    ///   - userName: The name of the user that is creating a profile.
    /// - Returns: Returns a slug for the profile of the User.
    ///
    /// >Important: The slug flows the following structure: `slug-based-representation-of-the-name-of-user-222333(<-random integer)`.
    static func generate(for userName: String) async throws -> String {
        let slug = userName.convertedToSlug()
        
        guard let slug else {
            throw Abort(.notAcceptable, reason: "Seams that the given name empty.")
        }
        
        var profileSlug = slug
        
        while await SlugCache.shared.has(profileSlug) {
            let slugSufix = Int.random(in: .min ... .max)
            let newProfileSlug = profileSlug + "\(slugSufix)"
            profileSlug = newProfileSlug
        }
        
        return profileSlug
    }
}
