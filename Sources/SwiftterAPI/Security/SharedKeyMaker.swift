//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/25/25.
//

import Vapor

enum SharedKeyMaker {
    /// Generates a shared key with the server private key and the given user's public key.
    /// - Parameter keyPair: A type that stores the id of where the server private key is stored and a data representation of the client public key
    /// - Returns: Returns a symmetric key representation of the shared key calculated between client public key and server private key.
    static func makeSharedKey(with keyPair: ECKeyPair) async throws -> SymmetricKey {
        let serverPrivateKey = await SecureKeysCache.shared[keyPair.privateKeyID]
        
        guard let serverPrivateKey else { throw Abort(.unauthorized) }
        
        let clientPublicKey = try PublicKey(rawRepresentation: keyPair.publicKey)
        
        return try await CryptographyHandler.generateSharedKey(with: clientPublicKey, and: serverPrivateKey)
    }
}
