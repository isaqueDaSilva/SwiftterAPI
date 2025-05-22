//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import JWT
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
        let newUser = try await UserService.create(with: createUserDTO, request: request)
        let userSlug = try await SlugGenerator.generate(for: newUser.name, with: request.db)
        let newProfile = try await UserProfileService.create(
            with: userSlug,
            userID: newUser.requireID(),
            at: request.db
        )
        
        let accessPayload = try Payload(with: newUser.requireID(), userSlug: userSlug, audienceType: .fullAccess)
        let accessToken = try await request.jwt.sign(accessPayload, kid: JWTSecretIdentifier.accessTokenSecreyKey.key)
        
        let refreshPayload = try Payload(with: newUser.requireID(), userSlug: userSlug, audienceType: .refresh)
        let refreshToken = try await request.jwt.sign(accessPayload, kid: JWTSecretIdentifier.refreshTokenSecreyKey.key)
        
        return try .init(accessToken: accessToken, refreshToken: refreshToken, userProfile: newProfile.toDTO())
    }
}
