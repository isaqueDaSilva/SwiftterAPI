//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/9/25.
//

import Fluent

/// A cache that stores a set of profile slugs in-memory,
/// to perform operations more quickly, like see if a slug already exists.
final actor SlugCache {
    /// A shared insatnce to access this cache from only one instance.
    static let shared = SlugCache()
    
    /// A set that stores the cache in-memory.
    private var slugs: Set<String> = []
    
    /// Add a new slug to the cache.
    /// - Returns: Returns a Boolean value indicating if the process was finished with success.
    func add(_ slug: String) {
        guard !self.has(slug) else { return }
        self.slugs.insert(slug)
    }
    
    /// Removes a slug from the cache,
    func remove(_ slug: String) {
        self.slugs.remove(slug)
    }
    
    /// Lookup at the cache and check if the slug already exists
    /// - Returns: Returns a boolean value indicating if the slug exist or not.
    func has(_ slug: String) -> Bool {
        self.slugs.contains(slug)
    }
    
    /// Initialize the cache, by fetching all slugs stored at the database, and put those at the cache.
    /// - Parameter database: The default detabase that the slugs are stored.
    func populate(with database: any Database) async throws {
        let slugs = try await UserProfile.query(on: database).field(\.$id).all().map({ try $0.requireID() })
        
        self.slugs = Set<String>(slugs)
    }
    
    private init() { }
}
