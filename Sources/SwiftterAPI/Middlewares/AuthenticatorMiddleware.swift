//
//  AuthenticatorMiddleware.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/23/25.
//

import Vapor

struct AuthenticatorMiddleware: AsyncBasicAuthenticator {
    func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        let keyPair = try request.content.decode(ECKeyPair.self)
        let sharedKey = try await makeSharedKey(with: keyPair)
        let encryptedPasswordData = try basic.password.toData()
        let decryptedPassword = try CryptographyHandler.decryptField(
            encryptedField: encryptedPasswordData,
            key: sharedKey
        )
        
        guard let decryptedPassword else { throw Abort(.unauthorized, reason: "Password is required.") }
        
        let user = try await UserService.getUser(by: basic.username, at: request.db)
        
        guard try Bcrypt.verify(decryptedPassword, created: user.passwordHash) else {
            throw Abort(.unauthorized)
        }
        
        request.auth.login(user)
    }
    
    /// Generates a shared key with the server private key and the given user's public key.
    /// - Parameter keyPair: A type that stores the id of where the server private key is stored and a data representation of the client public key
    /// - Returns: Returns a symmetric key representation of the shared key calculated between client public key and server private key.
    private func makeSharedKey(with keyPair: ECKeyPair) async throws -> SymmetricKey {
        let serverPrivateKey = await SecureKeysCache.shared[keyPair.privateKeyID]
        
        guard let serverPrivateKey else { throw Abort(.unauthorized) }
        
        let clientPublicKey = try PublicKey(rawRepresentation: keyPair.publicKey)
        
        return try await CryptographyHandler.generateSharedKey(with: clientPublicKey, and: serverPrivateKey)
    }
}
