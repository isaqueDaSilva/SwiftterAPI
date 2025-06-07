//
//  Swifeet.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/4/25.
//

import Fluent
import Vapor

/// A representation of an user's Swifeet on a database's table.
final class Swifeet: Model, @unchecked Sendable {
    static let schema = "swifeet"
    
    /// An unique identifier to identify a post.
    ///
    /// This identifier is composed by a profile slug, a random number and a date of creation of the swifeet in ISO 8601 style.
    @ID(custom: FieldName.id.key, generatedBy: .user)
    var id: String?
    
    /// The profile that mades this post.
    @Parent(key: FieldName.profileSlug.key)
    var profile: UserProfile
    
    /// The text body representation of the post.
    @OptionalField(key: FieldName.body.key)
    var body: String?
    
    /// The image url that is related with this post.
    @OptionalField(key: FieldName.imageName.key)
    var imageName: String?
    
    /// Stores the id of the original Swifeet, if it was an answer.
    @OptionalField(key: FieldName.answerOf.key)
    var answerOf: String?
    
    /// Stores the current count of answers for this swifeet.
    @Field(key: FieldName.answersCount.key)
    var answersCount: Int
    
    /// Stores a collection of likes.
    @Children(for: \.$swifeet)
    var likes: [Like]
    
    /// Stores the current count of likes for this swifeet.
    @Field(key: FieldName.likesCount.key)
    var likeCount: Int
    
    /// Indicates when this post was created.
    @Field(key: FieldName.createdAt.key)
    var createdAt: Date
    
    init() { }
    
    init(
        body: String?,
        imageName: String?,
        answerOf: String?,
        profileSlug: String
    ) {
        let createdAt = Date()
        
        self.id = profileSlug + "-" + "\(Int.random(in: .min ... .max))" + "-" + createdAt.ISO8601Format()
        self.$profile.id = profileSlug
        self.body = body
        self.imageName = imageName
        self.answerOf = answerOf
        self.answersCount = 0
        self.likeCount = 0
        self.createdAt = createdAt
    }
}

extension Swifeet: Convertable {
    typealias DTO = ReadSwifeet
    
    func toDTO() throws -> ReadSwifeet {
        try .init(
            id: self.requireID(),
            userSlug: self.profile.requireID(),
            body: self.body,
            imageName: self.imageName,
            answerOf: self.answerOf,
            answerCount: self.answersCount,
            likesCount: self.likeCount,
            createdAt: self.createdAt
        )
    }
}

extension Swifeet {
    func updateAnswersCount(with updateType: UpdateType, at database: any Database) async throws {
        switch updateType {
        case .increment:
            self.answersCount += 1
        case .decrement:
            guard answersCount > 0 else { return }
            
            self.answersCount -= 1
        }
        
        try await self.update(on: database)
    }
    
    func updateLikesCount(with updateType: UpdateType, at database: any Database) async throws {
        switch updateType {
        case .increment:
            self.likeCount += 1
        case .decrement:
            guard likeCount > 0 else { return }
            
            self.likeCount -= 1
        }
        
        try await self.update(on: database)
    }
}
