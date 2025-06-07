//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import Vapor

struct SwifeetController: RouteCollection, ProtectedRouteProtocol {
    private let swifeetIDParameterKey = "swifeetID"
    private let imageName = "imageName"
    
    func boot(routes: any RoutesBuilder) throws {
        let swifeetRoute = routes.grouped("swifeet")
        let tokenProtectedRoute = self.tokenProtectedRoute(with: swifeetRoute)
        
        tokenProtectedRoute.on(.POST, "create", body: .collect(maxSize: "1mb")) { try await self.create(with: $0) }
        tokenProtectedRoute.get("likes", .parameter(self.swifeetIDParameterKey)) { try await self.getUserThatLikePost(with: $0) }
        tokenProtectedRoute.get("replies", .parameter(self.swifeetIDParameterKey)) { try await self.getAnswers(with: $0) }
        tokenProtectedRoute.get("swifeet-image", .parameter(self.imageName)) { try await self.getSwifeetImage(with: $0) }
        tokenProtectedRoute.put("like", .parameter(self.swifeetIDParameterKey)) { try await self.likeToggle(with: $0) }
        tokenProtectedRoute.delete("delete", .parameter(self.swifeetIDParameterKey)) {
            try await self.deleteSwifeet(with: $0)
        }
    }
    
    @Sendable
    private func create(with request: Request) async throws -> ReadSwifeet {
        let payload = try request.auth.require(Payload.self)
        
        let createSwifeetDTO = try request.content.decode(CreateSwifeet.self)
        
        try createSwifeetDTO.hasALeastOneContent()
        
        let imageName: String? = if let imageData = createSwifeetDTO.imageData {
            try await SwifeetService.addImageAtFileSystem(with: payload.userSlug, imageData: imageData)
        } else {
            nil
        }
        
        do {
            let newSwifeet = try await SwifeetService.create(
                with: createSwifeetDTO,
                imageName: imageName,
                and: payload.userSlug,
                at: request.db
            )
            
            return try newSwifeet.toDTO()
        } catch {
            if let imageName {
                try await SwifeetService.removeImagesFromFileSystem(with: imageName)
            }
            
            throw error
        }
    }
    
    @Sendable
    private func likeToggle(with request: Request) async throws -> HTTPStatus {
        let payload = try request.auth.require(Payload.self)
        let swifeetID = try request.parameters.require(self.swifeetIDParameterKey)
        
        try await request.db.transaction { database in
            if let like = try await LikeService.findLike(
                with: swifeetID,
                profileSlug: payload.userSlug,
                at: database
            ) {
                try await withThrowingTaskGroup { group in
                    _ = group.addTaskUnlessCancelled {
                        try await like.delete(on: database)
                    }
                    
                    _ = group.addTaskUnlessCancelled {
                        try await like.swifeet.updateLikesCount(with: .decrement, at: database)
                    }
                    
                    guard try await group.next() != nil else {
                        group.cancelAll()
                        return
                    }
                }
            } else {
                guard let swifeet = try await Swifeet.find(swifeetID, on: database) else {
                    throw Abort(.notFound, reason: "Swifeet not found.")
                }
                
                try await Like(profileSlug: payload.userSlug, swifeetID: swifeetID).create(on: request.db)
                try await swifeet.updateLikesCount(with: .increment, at: database)
            }
        }
        
        return .ok
    }
    
    @Sendable
    private func getUserThatLikePost(with request: Request) async throws -> Page<ProfilePreview> {
        let payload = try request.auth.require(Payload.self)
        let swifeetID = try request.parameters.require(self.swifeetIDParameterKey)
        
        let likePagination = try await Like.query(on: request.db)
            .join(Swifeet.self, on: \Like.$swifeet.$id == \Swifeet.$id)
            .group(.and) { group in
                group
                    .filter(Swifeet.self, \.$id == swifeetID)
                    .filter(Swifeet.self, \.$profile.$id == payload.userSlug)
            }
            .with(\.$profile)
            .paginate(for: request)
        
        return try .init(items: likePagination.items.toProfilePreview(), metadata: likePagination.metadata)
    }
    
    @Sendable
    private func getAnswers(with request: Request) async throws -> Page<ReadSwifeet> {
        guard request.auth.has(Payload.self) else { throw Abort(.unauthorized) }
        
        let swifeetID = try request.parameters.require(self.swifeetIDParameterKey)
        
        let answers = try await Swifeet.query(on: request.db)
            .filter(\.$answerOf, .equal, swifeetID)
            .with(\.$likes)
            .paginate(for: request)
        
        let answersPage = try Page(items: answers.items.toDTOCollection(), metadata: answers.metadata)
        
        return answersPage
    }
    
    @Sendable
    private func deleteSwifeet(with request: Request) async throws -> HTTPStatus {
        let payload = try request.auth.require(Payload.self)
        let swifeetID = try request.parameters.require(self.swifeetIDParameterKey)
        
        let swifeet = try await Swifeet.query(on: request.db)
            .filter(\.$id, .equal, swifeetID)
            .with(\.$profile)
            .first()
        
        guard let swifeet, try swifeet.profile.requireID() == payload.userSlug else {
            throw Abort(.badRequest, reason: "Cannot possible to delete this swifeet.")
        }
        
        try await request.db.transaction { database in
            try await swifeet.delete(on: database)
            
            try await withThrowingTaskGroup { group in
                _ = group.addTaskUnlessCancelled {
                    try await swifeet.profile.updateSwifeetCount(with: .decrement, at: database)
                }
                
                if let answerOf = swifeet.answerOf {
                    _ = group.addTaskUnlessCancelled {
                        try await SwifeetService.updateAnswersCountForOriginalSwifteet(
                            with: answerOf,
                            type: .decrement,
                            at: database
                        )
                    }
                }
                
                guard try await group.next() != nil else {
                    group.cancelAll()
                    return
                }
            }
        }
        
        if let imageName = swifeet.imageName {
            try await SwifeetService.removeImagesFromFileSystem(with: imageName)
        }
        
        return .ok
    }
    
    @Sendable
    private func getSwifeetImage(with request: Request) async throws -> Picture {
        guard request.auth.has(Payload.self) else { throw Abort(.unauthorized) }
        
        let imageName = try request.parameters.require(self.imageName)
        
        let fullPath = try EnvironmentValues.swifeetPicturePath(with: imageName)
        let imageBuffer = try await FileSystemHandler.retrive(at: fullPath)
        
        return .init(data: .init(buffer: imageBuffer))
    }
}
