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
            with: createUserDTO.keyCollection.keyPairForPassword
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
    static func getUser(by email: String, at database: any Database) async throws -> User {
        let user = try await User.query(on: database)
            .filter(\.$email, .equal, email)
            .with(\.$profile)
            .field(\.$email)
            .field(\.$passwordHash)
            .first()
        
        guard let user else {
            throw Abort(.notFound)
        }
        
        return user
    }
}
