//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import Vapor

enum SwifeetService {
    static func create(
        with dto: CreateSwifeet,
        imageName: String?,
        and userSlug: String,
        at database: any Database
    ) async throws -> Swifeet {
        let newSwifeet: Swifeet = try await database.transaction { database in
            let newSwifeet = Swifeet(
                body: dto.body,
                imageName: imageName,
                answerOf: dto.answerOf,
                profileSlug: userSlug
            )
            
            try await newSwifeet.create(on: database)
            
            try await withThrowingTaskGroup { group in
                _ = group.addTaskUnlessCancelled {
                    let userProfile = try await UserProfileService.getProfile(by: userSlug, on: database)
                    try await userProfile.updateSwifeetCount(with: .increment, at: database)
                }
                
                _ = group.addTaskUnlessCancelled {
                    try await Self.updateAnswersCountForOriginalSwifteet(
                        with: newSwifeet.requireID(),
                        at: database
                    )
                }
                
                if let body = dto.body {
                    _ = group.addTaskUnlessCancelled {
                        try await TopicService.updateTopics(from: body, at: database)
                    }
                }
                
                guard try await group.next() != nil else {
                    group.cancelAll()
                    return
                }
            }
            
            return newSwifeet
        }
        
        return newSwifeet
    }
    
    static func updateAnswersCountForOriginalSwifteet(
        with swifeetID: String,
        type: UpdateType = .increment,
        at database: any Database
    ) async throws {
        let originalSwifeet = try await Swifeet.find(swifeetID, on: database)
        
        guard let originalSwifeet else { throw Abort(.notFound, reason: "Swifeet not available to perform action") }
        
        try await originalSwifeet.updateAnswersCount(with: .increment, at: database)
    }
    
    static func addImageAtFileSystem(with userSlug: String, imageData: Data) async throws -> String {
        let imageName = userSlug + "-" + Date().ISO8601Format() + "-" + "\(Int.random(in: .min ... .max))" + ".jpg"
        let fullPath = try EnvironmentValues.swifeetPicturePath(with: imageName)
        try await FileSystemHandler.write(.init(data: imageData), at: fullPath)
        
        return imageName
    }
    
    static func removeImagesFromFileSystem(with imageName: String) async throws {
        let fullPath = try EnvironmentValues.swifeetPicturePath(with: imageName)
        guard try await FileSystemHandler.delete(at: fullPath) else {
            throw Abort(.internalServerError)
        }
    }
}
