/// A representation table on database, that describe a relation between two user, known as follow action.
///
/// This action consists of a random user, known as a follower, finding a profile, random or not,
/// and following it, with the aim of monitoring its activity as a user of the platform.
final class Follow: Model, @unchecked Sendable {
    static let schema = "follow"
    
    /// An unique identifier that identifies the follow action.
    @ID(key: .id)
    var id: UUID?
    
    ///Indicates who's the user that started the relashionsip(follow action) between them.
    @Parent(key: FieldName.follower.key)
    var follower: UserProfile
    
    /// Indicates who's the user that followed by other user in the follow action.
    @Parent(key: FieldName.following.key)
    var following: UserProfile
    
    /// Indicates when occurred the action.
    @Timestamp(key: FieldName.followedAt.key, on: .create)
    var followedAt: Date?
    
    init() { }
    
    init(
        user: UserProfile.IDValue,
        following: UserProfile.IDValue
    ) {
        self.id = nil
        self.$follower.id = user
        self.$following.id = following
        self.followedAt = .now
    }
}