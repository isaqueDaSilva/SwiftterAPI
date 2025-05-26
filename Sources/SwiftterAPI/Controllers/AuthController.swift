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
        let refreshTokenBasedRoute = authRoute.grouped(VerifyAndDisableTokensMiddleware())
        
        authRoute.post("signup") { try await self.signUp(with: $0) }
        userProtectedRoute.post("signin") { try await self.signIn(with: $0) }
        refreshTokenBasedRoute.put("refresh-token") { try await self.refreshToken(with: $0) }
    }
}

extension AuthController {
    @Sendable
    private func signUp(with request: Request) async throws -> SignUpResponse {
        let createUserRequestDTO = try request.content.decode(CreateUserRequest.self)
        
        let newUser = try await UserService.create(with: createUserRequestDTO, request: request)
        let userSlug = try await SlugGenerator.generate(for: newUser.name, with: request.db)
        let newUserProfile = try await UserProfileService.create(
            with: userSlug,
            userID: newUser.requireID(),
            at: request.db
        )
        
        let clientPublicKey = createUserRequestDTO.keyCollection.publicKeyForEncryption
        
        return try await .build(
            with: newUser.requireID(),
            userProfile: newUserProfile,
            clientPublicKey: clientPublicKey,
            and: request
        )
    }
    
    @Sendable
    private func signIn(with request: Request) async throws -> SignInResponse {
        let user = try request.auth.require(User.self)
        let keyCollection = try request.content.decode(KeyCollection.self)
        let clientPublicKey = keyCollection.publicKeyForEncryption
        
        guard let userProfile = user.profile else { throw Abort(.unauthorized) }
        
        return try await .build(
            with: user.requireID(),
            userProfile: userProfile,
            clientPublicKey: clientPublicKey,
            and: request
        )
    }
    
    @Sendable
    private func refreshToken(with request: Request) async throws -> TokenPair {
        let refreshTokenPayload = try request.auth.require(Payload.self)
        guard let clientPublicKeyData = try await request.cache.get(KeyCollection.storageKey, as: Data.self) else {
            throw Abort(.internalServerError)
        }
        
        guard let userID = UUID(uuidString: refreshTokenPayload.subject.value) else {
            throw Abort(.unauthorized)
        }
        
        return try await JWTService.createPairOfJWT(
            userID: userID,
            userSlug: refreshTokenPayload.userSlug,
            clientPublicKeyData: clientPublicKeyData,
            request: request
        )
    }
}
