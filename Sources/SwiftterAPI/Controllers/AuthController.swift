//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let authRoute = routes.grouped("auth")
        
        authRoute.post("signup") { request async throws -> SignUpResponse in
            try await self.signUp(with: request)
        }
    }
}

extension AuthController {
    @Sendable
    private func signUp(with request: Request) async throws -> SignUpResponse {
        let createUserDTO = try request.content.decode(CreateUser.self)
        let newUser = try await UserServices.create(with: createUserDTO, request: request)
        let userSlug = try await SlugGenerator.generate(for: newUser.name, with: request.db)
        let newProfile = try await UserProfileServices.create(
            with: userSlug,
            userID: newUser.requireID(),
            at: request.db
        )
        
        // TODO: - Create the JWT -
        
        return try .init(accessToken: "", refreshToken: "", userProfile: newProfile.toDTO())
    }
}
