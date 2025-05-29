//
//  User.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent
import Vapor

/// A representation of an User on a database's table.
final class User: Model, @unchecked Sendable {
    static let schema = "user"
    
    /// An unique UUID that identifies an user on database table.
    @ID(custom: FieldName.id.key, generatedBy: .user)
    var id: String?
    
    /// The actual name of an user.
    @Field(key: FieldName.name.key)
    var name: String
    
    /// The  birthday of the user.
    ///
    /// > Important: Only users with 13 years or more is valid to subscribe on the plataform.
    @Field(key: FieldName.birthDate.key)
    var birthDate: Date
    
    /// The email of an user that is used to perform the authentication process.
    ///
    /// > Important: The email needs to be unique, to authenticate user correctly and secure.
    @Field(key: FieldName.email.key)
    var email: String
    
    /// The hashed representation of the User's password.
    @Field(key: FieldName.passwordHash.key)
    var passwordHash: String
    
    /// The exact time that a user was created.
    @Field(key: FieldName.createdAt.key)
    var createdAt: Date?
    
    /// Indicates if the user is current logged or not.
    @Field(key: FieldName.isLogged.key)
    var isLogged: Bool
    
    /// The profile of the user.
    ///
    /// >Note: Although it is noted as optional child, the user profile persists as long as the user exists.
    @OptionalChild(for: \.$user)
    var profile: UserProfile?
    
    init() { }
    
    /// Create a new user instance.
    init(
        from dto: CreateUserRequest,
        passwordHash: String
    ) {
        self.id = UUID().uuidString
        self.name = dto.name
        self.email = dto.email.lowercased()
        self.passwordHash = passwordHash
        self.birthDate = dto.birthDate
        self.createdAt = .now
        self.isLogged = true
    }
}

extension User: Authenticatable {
    func updateLoggedStatus(with isLogged: Bool, on database: any Database) async throws {
        guard isLogged != self.isLogged else { return }
        
        self.isLogged = isLogged
        
        try await self.update(on: database)
    }
}
