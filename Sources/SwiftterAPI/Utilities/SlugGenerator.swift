//
//  SlugGenerator.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor
import Fluent

enum SlugGenerator {
    /// Generates a slug for an user profile, based on your name.
    /// - Parameters:
    ///   - userName: The name of the user that is creating a profile.
    ///   - database: The database representation that will performed some checks to see if the slug already exists.
    /// - Returns: Returns a slug for the profile of the User.
    ///
    /// >Important: The slug flows the following structure: `slug-based-representation-of-the-name-of-user-222333(<-random integer)`.
    static func generate(for userName: String, with database: any Database) async throws -> String {
        let slug = userName.convertedToSlug()
        
        guard let slug else {
            throw Abort(.notAcceptable, reason: "Seams that the given name empty.")
        }
        
        var userSlug = slug
        
        while try await checkIfTheUserSlugExist(userSlug, on: database) {
            let slugSufix = Int.random(in: .min ... .max)
            let newUserSlug = userSlug + "\(slugSufix)"
            userSlug = newUserSlug
        }
        
        return userSlug
    }
    
    /// Checks if the slug already exists.
    /// - Parameters:
    ///   - slug: The generated slug.
    ///   - database: The database representation that will performed some checks to see if the slug already exists.
    /// - Returns: A boolean value that indicates if the slug exists or not.
    private static func checkIfTheUserSlugExist(_ slug: String, on database: any Database) async throws -> Bool {
        guard try await UserProfile.query(on: database)
            .filter(\.$id, .equal, slug)
            .count() == 0
        else {
            return true
        }
        
        return false
    }
}
