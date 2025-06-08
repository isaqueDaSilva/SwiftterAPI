//
//  SecureKeysCache.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Collections
import Crypto
import Vapor

/// An in-memory data structure that stores private keys to be used after to perform decryption of some field.
final actor SecureKeysCache {
    /// A shared instance to access this cache.
    static let shared = SecureKeysCache()
    
    private var deleterTask: Task<Void, Never>? = nil
    
    private var privateKeys: [UUID: PrivateKey] = [:]
    private var deleterQueue: OrderedDictionary<UUID, Date> = [:]
    
    /// Adds a new key at the storage.
    /// - Parameters:
    ///   - privateKey: The private key representation that will be store.
    ///   - id: An identifier for the key.
    func add(_ privateKey: PrivateKey, for id: UUID) {
        let twoMinutesInterval: TimeInterval = 60 * 2
        let twoMinutesFromNow = Date().addingTimeInterval(twoMinutesInterval)
        self.privateKeys[id] = privateKey
        self.deleterQueue[id] = twoMinutesFromNow
        
        if self.deleterTask == nil {
            self.deleterTask?.cancel()
            self.deleterTask = Task.detached(priority: .background) { await self.check() }
        }
    }
    
    /// Removes a key from the storage.
    /// - Parameter id: The id of the key that will be removed.
    func remove(for id: UUID) {
        self.privateKeys[id] = nil
        self.deleterQueue[id] = nil
        
        if privateKeys.isEmpty && deleterQueue.isEmpty {
            self.deleterTask?.cancel()
            self.deleterTask = nil
        }
    }
    
    /// Schedule a periodic checker to check if the header key is expired or not, when the cache is not empty.
    private func check() async {
        while !self.deleterQueue.isEmpty && !self.privateKeys.isEmpty {
            let (id, date) = (self.deleterQueue.keys.first, self.deleterQueue.values.first)
            
            if let date, let id, date <= Date() {
                self.remove(for: id)
            }
            
            try? await Task.sleep(for: .seconds(120))
        }
    }
    
    subscript(_ id: UUID) -> PrivateKey? {
        let key = self.privateKeys[id]
        
        if key != nil {
            self.remove(for: id)
        }
        
        return key
    }
    
    private init() { }
    
    deinit {
        self.deleterTask?.cancel()
        self.deleterTask = nil
        self.privateKeys.removeAll()
        self.deleterQueue.removeAll()
    }
}
