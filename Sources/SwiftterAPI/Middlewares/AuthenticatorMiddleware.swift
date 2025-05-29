//
//  AuthenticatorMiddleware.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/23/25.
//

import Vapor

struct AuthenticatorMiddleware: AsyncBasicAuthenticator {
    func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        let keyCollection = try request.content.decode(KeyCollection.self)
        let sharedKey = try await SharedKeyMaker.makeSharedKey(with: keyCollection.keyPairForDecryption)
        let encryptedPasswordData = try basic.password.toData()
        let decryptedPassword = try CryptographyHandler.decryptField(
            encryptedField: encryptedPasswordData,
            key: sharedKey
        )
        
        guard let decryptedPassword else { throw Abort(.unauthorized, reason: "Password is required.") }
        
        let user = try await UserService.getUser(byEmail: basic.username, at: request.db)
        
        guard !user.isLogged else {
            throw Abort(.unauthorized)
        }
        
        guard try Bcrypt.verify(decryptedPassword, created: user.passwordHash), !user.isLogged else {
            throw Abort(.unauthorized)
        }
        
        request.auth.login(user)
    }
}
