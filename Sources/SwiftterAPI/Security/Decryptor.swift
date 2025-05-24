//
//  Decryptor.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

enum Decryptor {
    /// Decrypts an encrypted field with the shared secret process.
    /// - Parameters:
    ///   - field: The data representation of the field.
    ///   - publicKey: The client's public key to perform the shared key calculation.
    /// - Returns: Returns a string representation of the encrypted field.
    static func decryptField(_ field: Data, with keyPair: ECKeyPair) async throws -> String {
        guard let serverPrivateKey = await SecureKeysCache.shared[keyPair.privateKeyID] else {
            throw Abort(.internalServerError, reason: "No Server's private key available.")
        }
        
        await SecureKeysCache.shared.remove(for: keyPair.privateKeyID)
        
        let clientPublicKey = try PublicKey(rawRepresentation: keyPair.publicKey)
        
        let sharedKey = try await CryptographyHandler.generateSharedKey(
            with: clientPublicKey,
            and: serverPrivateKey
        )
        
        let decryptedField = try CryptographyHandler.decryptField(
            encryptedField: field,
            key: sharedKey
        )
        
        guard let decryptedField else {
            throw Abort(
                .notAcceptable,
                reason: "The server cannot decrypt the client's password correctly."
            )
        }
        
        return decryptedField
    }
}
