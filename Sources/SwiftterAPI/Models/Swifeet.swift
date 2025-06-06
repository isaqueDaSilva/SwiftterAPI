import Fluent
import Vapor

/// A representation of an user's Swifeet on a database's table.
final class Swifeet: Model, @unchecked Sendable {
    static let schema = "swifeet"
    
    /// An unique identifier to identify the user's post.
    ///
    /// This identifier is composed by a user slug,  the creation date of the swifeet in ISO 8601 style and a random number.
    @ID(custom: FieldName.id.key, generatedBy: .user)
    var id: String?
    
    /// The user that made this post.
    @Parent(key: FieldName.userProfileID.key)
    var user: UserProfile
    
    /// The text body representation of the post.
    @OptionalField(key: FieldName.body.key)
    var body: String?
    
    /// The image url that is related with this post.
    @OptionalField(key: FieldName.imageName.key)
    var imageName: String?
    
    /// An identifier that indicates if this post is an origial post or a answer of some other post.
    ///
    /// >Note: When this post will be an original post, this field will be setted as "Original", but when this post will be an answer, this field will be setted with the identifier of the original swifeet..
    @Field(key: FieldName.answerOf.key)
    var answerOf: String
    
    /// Stores the current count of likes for this swifeet.
    @Field(key: FieldName.likesCount.key)
    var likeCount: Int
    
    /// Stores the current count of answers for this swifeet.
    @Field(key: FieldName.answersCount.key)
    var answersCount: Int
    
    /// Stores a collection of likes.
    @Children(for: \.$swifeet)
    var likes: [Like]
    
    /// A boolean value that indicates if the swifeet is alive or was deleted by user.
    @Field(key: FieldName.isDeleted.key)
    var isDeleted: Bool
    
    /// Indicates when this post was created.
    @Field(key: FieldName.createdAt.key)
    var createdAt: Date
    
    init() { }
    
    init(
        with dto: CreateSwifeet,
        userSlug: String,
        imageName: String?
    ) {
        let createdAt = Date()
        
        self.id = userSlug + createdAt.ISO8601Format().lowercased() + "\(Int.random(in: .min ... .max))"
        self.$user.id = userSlug
        self.body = dto.body
        self.imageName = imageName
        self.answerOf = dto.answerOf ?? Self.defaultAnswerOf
        self.likeCount = 0
        self.answersCount = 0
        self.isDeleted = false
        self.createdAt = createdAt
    }
}