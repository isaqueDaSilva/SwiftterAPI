import Vapor

struct ReadSwifeet: Content {
    let id: String
    let userSlug: String
    let body: String?
    let imageName: String?
    let likes: [ReadLikes]
    let answerOf: String
    let isDeleted: Bool
    let createdAt: Date
}