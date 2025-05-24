//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import JWT
import Vapor

struct AuthController: RouteCollection, ProtectedRouteProtocol {
    func boot(routes: any RoutesBuilder) throws {
        let authRoute = routes.grouped("auth")
        let userProtectedRoute = userProtectedRoute(with: authRoute)
        
        authRoute.post("signup") { try await self.signUp(with: $0) }
        userProtectedRoute.post("signin") { try await self.signIn(with: $0) }
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
        
        let clientPublicKey = createUserRequestDTO.keyCollection.publicKeyForToken
        
        let (accessToken, refreshToken, publicKey) = try await JWTService.createPairOfJWT(
            userID: newUser.requireID(),
            userSlug: userSlug,
            clientPublicKeyData: clientPublicKey,
            request: request
        )
        
        return try .init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            serverPublicKey: publicKey,
            userProfile: newProfile.toDTO()
        )
    }
    
    @Sendable
    private func signIn(with request: Request) async throws -> SignInResponse {
        let user = try request.auth.require(User.self)
        let keyCollection = try request.content.decode(KeyCollection.self)
        let clientPublicKey = keyCollection.publicKeyForToken
        
        guard let userProfile = user.profile else { throw Abort(.unauthorized) }
        
        let (accessToken, refreshToken, publicKey) = try await JWTService.createPairOfJWT(
            userID: user.requireID(),
            userSlug: userProfile.requireID(),
            clientPublicKeyData: clientPublicKey,
            request: request
        )
        
        return try .init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            serverPublicKey: publicKey,
            userProfile: userProfile.toDTO()
        )
    }
}
