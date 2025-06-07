//
//  Topic.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import Vapor

///A representation table for a topic on the database.
final class Topic: Model, @unchecked Sendable {
    static let schema = "topic"
    
    /// An unique identifier for a topic on database.
    @ID(custom: FieldName.id.key, generatedBy: .user)
    var id: UUID?
    
    /// A representation for an topic.
    @Field(key: FieldName.topic.key)
    var topic: String
    
    /// Indicates how many times this topic was mentioned.
    @Field(key: FieldName.counter.key)
    var counter: Int
    
    /// Indicates when this topic was mentioned for the first time.
    @Field(key: FieldName.createdAt.key)
    var createdAt: Date
    
    /// Indicates the last time that this topic was mentioned.
    @Field(key: FieldName.updatedAt.key)
    var updatedAt: Date
    
    init() { }
    
    init(topicName: String) {
        self.id = .init()
        self.topic = topicName
        self.counter = 1
        self.createdAt = .now
        self.updatedAt = .now
    }
}

extension Topic {
    func updateCounter(on database: any Database) async throws {
        self.counter += 1
        
        try await self.update(on: database)
    }
}

