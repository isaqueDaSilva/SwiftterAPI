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
    static func decryptField(_ field: Data, with publicKey: ECPublicKey) async throws -> String {
        let sharedKey = try await SecureCommunicationHandler.generateSharedKey(for: publicKey)
        
        let decryptedField = try SecureCommunicationHandler.decryptField(
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
