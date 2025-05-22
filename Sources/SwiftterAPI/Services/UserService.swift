//
//  File.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

enum UserService {
    /// Creates a new user at the database.
    /// - Parameter request: The main request object that is responsible to perform the operation.
    /// - Returns: Returns an instance of the generated user.
    static func create(with createUserDTO: CreateUserRequest, request: Request) async throws -> User {
        try CreateUserRequest.validate(content: request)
        
        let password = try await Decryptor.decryptField(
            createUserDTO.password,
            with: createUserDTO.publicKeyForPassword
        )
        
        guard PasswordChecker.check(password) else {
            throw Abort(.notAcceptable, reason: "The password is not valid to create a profile.")
        }

        let passwordHash = try Bcrypt.hash(password)
        
        let newUser = User(from: createUserDTO, passwordHash: passwordHash)
        try await newUser.create(on: request.db)
        
        return newUser
    }
}
