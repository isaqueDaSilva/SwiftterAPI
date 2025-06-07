//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import Vapor

enum TopicService {
    static func updateTopics(from body: String, at database: any Database) async throws {
        let topics = TopicIdentifier.identify(at: body)
        
        guard !topics.isEmpty else { return }
        
        for topic in topics {
            try await Self.updatePopularity(for: topic, at: database)
        }
    }
    
    static func updatePopularity(for topic: String, at database: any Database) async throws {
        if let topic = try await Topic
            .query(on: database)
            .filter(\.$topic, .equal, topic)
            .first()
        {
            try await topic.updateCounter(on: database)
        } else {
            try await Topic(topicName: topic).create(on: database)
        }
    }
}
