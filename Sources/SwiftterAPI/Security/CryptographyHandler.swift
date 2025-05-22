//
//  CryptographyHandler.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Crypto
import Vapor

typealias PrivateKey = P384.KeyAgreement.PrivateKey
typealias PublicKey = P384.KeyAgreement.PublicKey

/// A handler object that is responsable to execute functions releted of key exchange and decrytion.
enum CryptographyHandler {
    
    /// Generates a pair of server's public and private key.
    /// - Returns: Returns a server public key
    ///
    /// When the server generate a pair of key, the private key is stored locally on a server's cache,
    /// and the public key is sent to user, to perform a encryption process.
    static func generatesPublicKey() async throws -> ECKeyPair {
        let privateKey = PrivateKey()
        let label = UUID()
        await SecureKeysCache.shared.add(privateKey, for: label)
        let publicKey = privateKey.publicKey.rawRepresentation
        return .init(privateKeyID: label, publicKey: publicKey)
    }
    
    /// Performs a calculation to generate a shared key, between serve's private key and client's public key, to decrypt a given encrypted field.
    /// - Parameter clientKey: The given client's public key.
    /// - Returns: Returns a shared key value to decrypt the field.
    static func generateSharedKey(with publicKey: PublicKey, and privateKey: PrivateKey) async throws -> SymmetricKey {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        
        let symmetricKey = sharedSecret.x963DerivedSymmetricKey(
            using: SHA512.self,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        return symmetricKey
    }
    
    /// Encrypts a field using a share key process.
    /// - Parameters:
    ///   - field: The field that will be encrypted.
    ///   - privateKey: A private key that will be used to calculate a shared key.
    ///   - publicKey: A public key that will be used to calculate a shared key.
    /// - Returns: Returns a Data representation of the encrypted field.
    static func encryptField(_ field: Data, with privateKey: PrivateKey, and publicKey: PublicKey) async throws -> Data {
        let sharedKey = try await Self.generateSharedKey(with: publicKey, and: privateKey)
        
        let sealedBox = try AES.GCM.seal(field, using: sharedKey, nonce: .init())

        guard let encryptedToken = sealedBox.combined else {
            throw Abort(.internalServerError, reason: "Error to generate refresh token.")
        }
        
        return encryptedToken
    }
    
    /// Decrypt a given encrypted field.
    /// - Parameters:
    ///   - encryptedField: An encrypted field data representtion.
    ///   - key: A shared key value, calculated between server's private key and client's public key.
    ///   See ``generatesPublicKey()`` to get more information about the process,.
    /// - Returns: Returns a String representation of the encrypted field.
    static func decryptField(encryptedField: Data, key: SymmetricKey) throws -> String? {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedField)
        
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        return String(data: decryptedData, encoding: .utf8)
    }
}
