//
//  File.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent
import Vapor

enum UserService {
    /// Creates a new user at the database.
    /// - Parameter request: The main request object that is responsible to perform the operation.
    /// - Returns: Returns an instance of the generated user.
    static func create(with createUserDTO: CreateUserRequest, request: Request) async throws -> User {
        try CreateUserRequest.validate(content: request)
        
        let password = try await Decryptor.decryptField(
            createUserDTO.password,
            with: createUserDTO.keyCollection.keyPairForDecryption
        )
        
        guard PasswordChecker.check(password) else {
            throw Abort(.notAcceptable, reason: "The password is not valid to create a profile.")
        }

        let passwordHash = try Bcrypt.hash(password)
        
        let newUser = User(from: createUserDTO, passwordHash: passwordHash)
        try await newUser.create(on: request.db)
        
        return newUser
    }
    
    /// Loads an user representation from database with your email and password, along side with your profile.
    /// - Parameters:
    ///   - email: The email of the user that is used to get a user.
    ///   - database: The database client representation to mediates the communication between the API and the Database system.
    /// - Returns: Returns a representation of an user that matches with the given email.
    static func getUser(byEmail email: String, at database: any Database) async throws -> User {
        let user = try await User.query(on: database)
            .filter(\.$email, .equal, email)
            .with(\.$profile)
            .first()
        
        guard let user else {
            throw Abort(.notFound)
        }
        
        return user
    }
    
    /// Gets an user by your id value.
    /// - Parameters:
    ///   - id: The id of the user that is requested to find,
    ///   - withProfie: A boolean value that idicates if we want to fetch the user profile as well or not.
    ///   - database: The database client representation to mediates the communication between the API and the Database system.
    /// - Returns: Returns an optional instance, where if the user was find, the value will be there or if not, the value will be nil.
    static func getUser(
        byID id: String,
        withProfie: Bool = true,
        at database: any Database
    ) async throws -> User {
        let query = User.query(on: database).filter(\.$id, .equal, id)
        
        let user = if withProfie {
            try await query.with(\.$profile).first()
        } else {
            try await query.first()
        }
        
        guard let user else {
            throw Abort(.notFound)
        }
        
        return user
    }
    
    /// Checks if the subject and the userSlug claims, stored at the payload, are valid.
    /// - Parameters:
    ///   - userID: The id of the user, stored at the `subject`claim of the payload.
    ///   - userSlug: The slug of the user.
    ///   - database: The database client representation to mediates the communication between the API and the Database system.
    static func isUserInformationsValid(
        _ userID: String,
        userSlug: String,
        on database: any Database
    ) async throws -> Bool {
        let user = try await UserService.getUser(byID: userID, at: database)
        
        guard try user.profile?.requireID() == userSlug else {
            return false
        }
        
        guard user.isLogged else {
            return false
        }
        
        return true
    }
    
    /// Revokes the logged status for a user.
    /// - Parameters:
    ///   - userID: The id of the user.
    ///   - database: The database client representation to mediates the communication between the API and the Database system.
    static func revokeUserAccess(
        for userID: String,
        tokens: [String: Payload],
        at database: any Database
    ) async throws {
        let user = try await Self.getUser(byID: userID, withProfie: false, at: database)
        
        try await withThrowingTaskGroup { group in
            for (token, payload) in tokens {
                _ = group.addTaskUnlessCancelled {
                    try await JWTService.disableToken(with: payload.jwtID.value, tokenValue: token, on: database)
                }
            }
            
            guard try await group.next() != nil else {
                group.cancelAll()
                return
            }
        }
        
        try await user.updateLoggedStatus(with: false, on: database)
    }
}
