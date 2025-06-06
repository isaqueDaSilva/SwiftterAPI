import Fluent
import Vapor

///A representation table for a topic on the database.
final class Topic: Model, @unchecked Sendable {
    static let schema = "topic"
    
    /// An unique identifier for a topic on database.
    @ID(key: .id)
    var id: UUID?
    
    /// A representation for an topic.
    @Field(key: FieldName.topic.key)
    var topic: String
    
    /// Indicates how many times this topic was mentioned.
    @Field(key: FieldName.counter.key)
    var counter: Int
    
    /// Indicates when this topic was mentioned for the first time.
    @Timestamp(key: FieldName.createdAt.key, on: .create)
    var createdAt: Date?
    
    /// Indicates the last time that this topic was mentioned.
    @Timestamp(key: FieldName.updatedAt.key, on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(
        _ topic: String
    ) {
        self.id = nil
        self.topic = topic
        self.counter = 1
        self.createdAt = nil
        self.updatedAt = nil
    }
}