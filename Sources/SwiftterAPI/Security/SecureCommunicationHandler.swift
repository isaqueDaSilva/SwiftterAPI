//
//  SecureCommunicationHandler.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Crypto
import Vapor

typealias PrivateKey = P384.KeyAgreement.PrivateKey
typealias PublicKey = P384.KeyAgreement.PublicKey

/// A handler object that is responsable to execute functions releted of key exchange and decrytion.
enum SecureCommunicationHandler {
    
    /// Generates a pair of server's public and private key.
    /// - Returns: Returns a server public key
    ///
    /// When the server generate a pair of key, the private key is stored locally on a server's cache,
    /// and the public key is sent to user, to perform a encryption process.
    static func generatesPublicKey() async throws -> ECPublicKey {
        let privateKey = PrivateKey()
        let label = UUID()
        await SecureKeysCache.shared.add(privateKey, for: label)
        let publicKey = privateKey.publicKey.rawRepresentation
        return .init(id: label, publicKey: publicKey)
    }
    
    /// Performs a calculation to generate a shared key, between serve's private key and client's public key, to decrypt a given encrypted field.
    /// - Parameter clientKey: The given client's public key.
    /// - Returns: Returns a shared key value to decrypt the field.
    static func generateSharedKey(for clientKey: ECPublicKey) async throws -> SymmetricKey {
        guard let serverPrivateKey = await SecureKeysCache.shared[clientKey.id] else {
            throw Abort(.internalServerError, reason: "No Server's private key available.")
        }
        
        let clientPublicKey = try PublicKey(rawRepresentation: clientKey.publicKey)
        
        let sharedSecret = try serverPrivateKey.sharedSecretFromKeyAgreement(with: clientPublicKey)
        
        let symmetricKey = sharedSecret.x963DerivedSymmetricKey(
            using: SHA512.self,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        await SecureKeysCache.shared.remove(for: clientKey.id)
        
        return symmetricKey
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
