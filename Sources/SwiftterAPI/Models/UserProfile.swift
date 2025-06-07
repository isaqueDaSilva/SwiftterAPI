//
//  UserProfile.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent
import Vapor

/// Representation model for a user public profile on a database's table.
final class UserProfile: Model, @unchecked Sendable {
    static let schema = "user_profile"
    
    /// An unique user's slug for identify a user profile in the database.
    @ID(custom: FieldName.slug.key, generatedBy: .user)
    var id: String?
    
    /// The parent user that this profile profile belongs to.
    @Parent(key: FieldName.userID.key)
    var user: User
    
    ///The user's profile picture name representation.
    ///
    /// This name representation is used to precompute an URL
    /// and fetch the user's profile image and display for him or anyone that access his profile.
    @Field(key: FieldName.profilePictureName.key)
    var profilePictureName: String
    
    /// The cover image name of the user's profile.
    ///
    /// This name representation is used to precompute an URL
    /// and fetch the user's cover image and display for him or anyone that access his profile.
    @Field(key: FieldName.coverImageName.key)
    var coverImageName: String
    
    /// The optional bio that the user can insert to express more about him.
    @OptionalField(key: FieldName.bio.key)
    var bio: String?
    
    /// The optional link that the user can insert to says for anyone that is visiting him,
    /// other ways to find him (e.g. GitHub profile, Instagram and more).
    @OptionalField(key: FieldName.link.key)
    var link: String?
    
    /// Stores the full representation of `followers` relashionship.
    @Siblings(through: Follow.self, from: \.$following, to: \.$follower)
    var followers: [UserProfile]
    
    /// Stores the total quantity of followers this profile has.
    @Field(key: FieldName.followersCount.key)
    var followersCount: Int
    
    /// Stores the full representation of the `following` relationship.
    @Siblings(through: Follow.self, from: \.$follower, to: \.$following)
    var following: [UserProfile]
    
    /// Stores the total count of followings that this profile has.
    @Field(key: FieldName.followingCount.key)
    var followingCount: Int
    
    /// Stores the total count of swifeets that this profile made.
    @Field(key: FieldName.swifeetCount.key)
    var swifeetCount: Int
    
    /// The exact time that a user was created.
    @Field(key: FieldName.createdAt.key)
    var createdAt: Date
    
    init() { }
    
    init(
        id: String,
        userID: User.IDValue
    ) {
        self.id = id
        self.$user.id = userID
        self.profilePictureName = Self.defaultImageName
        self.coverImageName = Self.defaultImageName
        self.bio = nil
        self.link = nil
        self.followersCount = 0
        self.followingCount = 0
        self.swifeetCount = 0
        self.createdAt = .now
    }
}

extension UserProfile {
    static let defaultImageName = "default.jpg"
}

extension UserProfile: Convertable {
    /// Transform the database representation model into a DTO model to send back as a response.
    /// - Returns: Retuns a DTO representation of this profile.
    func toDTO() throws -> Profile {
        try .init(
            slug: self.requireID(),
            profilePictureName: self.profilePictureName,
            coverImageName: self.coverImageName,
            bio: self.bio,
            link: self.link,
            followersCount: self.followersCount,
            followingCount: self.followingCount,
            swifeetCount: self.swifeetCount,
            createdAt: self.createdAt
        )
    }
}

extension UserProfile {
    func updateFollowersCount(with type: UpdateType, at database: any Database) async throws {
        switch type {
        case .increment:
            self.followersCount += 1
        case .decrement:
            guard followersCount > 0 else { return }
            
            self.followersCount -= 1
        }
        
        try await self.update(on: database)
    }
    
    func updateFollowingCount(with type: UpdateType, at database: any Database) async throws {
        switch type {
        case .increment:
            self.followingCount += 1
        case .decrement:
            guard followingCount > 0 else { return }
            
            self.followingCount -= 1
        }
        
        try await self.update(on: database)
    }
    
    func updateSwifeetCount(with type: UpdateType, at database: any Database) async throws {
        switch type {
        case .increment:
            self.swifeetCount += 1
        case .decrement:
            guard swifeetCount > 0 else { return }
            
            self.swifeetCount -= 1
        }
        
        try await self.update(on: database)
    }
    
    func updateFields(with dto: UpdateProfile, at database: any Database) async throws -> UserProfile {
        if let bio = dto.bio, self.bio != bio {
            self.bio = bio
        }
        
        if let link = dto.link, self.link != link {
            self.link = link
        }
        
        try await self.update(on: database)
        
        return self
    }
    
    func updatePicturesName(with name: String, for field: PictureField, at database: any Database) async throws {
        switch field {
        case .profile:
            self.profilePictureName = name
        case .cover:
            self.coverImageName = name
        }
        
        try await self.update(on: database)
    }
}

extension UserProfile {
    enum PictureField {
        case profile, cover
    }
}
