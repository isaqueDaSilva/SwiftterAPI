//
//  SecureKeysCache.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Crypto
import Vapor

/// An in-memory data structure that stores private keys to be used after to perform decryption of some field.
final actor SecureKeysCache {
    /// A shared instance to access this cache.
    static let shared = SecureKeysCache()
    
    private var privateKeys: [UUID: PrivateKey] = [:]
    
    
    /// Adds a new key at the storage.
    /// - Parameters:
    ///   - privateKey: The private key representation that will be store.
    ///   - id: An identifier for the key.
    func add(_ privateKey: PrivateKey, for id: UUID) {
        self.privateKeys[id] = privateKey
    }
    
    
    /// Removes a key from the storage.
    /// - Parameter id: The id of the key that will be removed.
    func remove(for id: UUID) { privateKeys[id] = nil }
    
    subscript(_ id: UUID) -> PrivateKey? {
        let key = privateKeys[id]
        
        if key != nil {
            self.remove(for: id)
        }
        
        return key
    }
    
    private init() { }
}
