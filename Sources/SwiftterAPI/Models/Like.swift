//
//  Like.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import Vapor

/// A representation of an user's like, on a Swifeet, at a database's table.
final class Like: Model, @unchecked Sendable {
    static let schema = "swifeet_like"
    
    /// An unique identifier for each like in the system.
    ///
    /// This identifier is composed by the slug of the user and the id of the swifeet.
    /// With this, is possible to apply a constraint that restrict the same user to like the same post twice,
    /// since this identifier needs to be unique for each like.
    ///
    /// The structure of the ID follows the structure bellow:
    /// ```
    /// LIKE-profileid-swifeetid
    /// ```
    ///
    /// >Important: The database checks the expression before to record the Like. If the id not flow the above structure an error will be throw.
    @ID(custom: FieldName.id.key, generatedBy: .user)
    var id: String?
    
    /// The user that create the like.
    @Parent(key: FieldName.profileSlug.key)
    var user: UserProfile
    
    /// The swifeet that the user made the like.
    @Parent(key: FieldName.swifeetID.key)
    var swifeet: Swifeet
    
    @Timestamp(key: FieldName.likedAt.key, on: .create)
    var likedAt: Date?
    
    init() { }
    
    init(userSlug: UserProfile.IDValue, swifeetID: Swifeet.IDValue) {
        self.id = "LIKE" + "-" + userSlug + "-" + swifeetID
        self.$user.id = userSlug
        self.$swifeet.id = swifeetID
        self.likedAt = nil
    }
}
