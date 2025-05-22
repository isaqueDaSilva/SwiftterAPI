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
        let createUserRequestDTO = try request.content.decode(CreateUserRequest.self)
        
        let newUser = try await UserService.create(with: createUserRequestDTO, request: request)
        let userSlug = try await SlugGenerator.generate(for: newUser.name, with: request.db)
        let newProfile = try await UserProfileService.create(
            with: userSlug,
            userID: newUser.requireID(),
            at: request.db
        )
        
        let (accessToken, refreshToken, publicKey) = try await JWTService.createPairOfJWT(
            userID: newUser.requireID(),
            userSlug: userSlug,
            clientPublicKeyData: createUserRequestDTO.publicKeyForToken,
            request: request
        )
        
        return try .init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            serverPublicKey: publicKey,
            userProfile: newProfile.toDTO()
        )
    }
}
