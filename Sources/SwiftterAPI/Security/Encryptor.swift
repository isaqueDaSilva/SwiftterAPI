//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/22/25.
//

import Vapor

enum Encryptor {
    /// Encrypts an field using a shared key.
    /// - Parameters:
    ///   - field: The field data representation that will be encrypted.
    ///   - privateKey: Some private key used to calculate a shared key.
    ///   - publicKey: Some public key used to calculate a shared key.
    /// - Returns: Returns a Data representation of the encrypted field.
    static func encrypts(
        _ field: Data,
        with privateKey: PrivateKey,
        and publicKey: PublicKey
    ) async throws -> Data {
        let encryptedField = try await CryptographyHandler.encryptField(
            field,
            with: privateKey,
            and: publicKey
        )
        
        return encryptedField
    }
}
