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
        let tokenProtectedRoute = self.tokenProtectedRoute(with: authRoute)
        
        authRoute.post("signup") { try await self.signUp(with: $0) }
        userProtectedRoute.post("signin") { try await self.signIn(with: $0) }
        refreshTokenBasedRoute.put("refresh-token") { try await self.refreshToken(with: $0) }
        tokenProtectedRoute.delete("signout") { try await self.signOut(with: $0) }
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
        
        let response = try await SignInResponse.build(
            with: user.requireID(),
            userProfile: userProfile,
            clientPublicKey: clientPublicKey,
            and: request
        )
        
        try await user.updateLoggedStatus(with: true, on: request.db)
        
        return response
    }
    
    @Sendable
    private func refreshToken(with request: Request) async throws -> TokenPair {
        let refreshTokenPayload = try request.auth.require(Payload.self)
        let storageKey = FieldsForTokenRefresh.storageKey
        
        guard let clientPublicKeyData = try await request.cache.get(storageKey, as: Data.self) else {
            throw Abort(.internalServerError)
        }
        
        try await request.cache.delete(storageKey)
        
        return try await JWTService.createPairOfJWT(
            userID: refreshTokenPayload.subject.value,
            userSlug: refreshTokenPayload.userSlug,
            clientPublicKeyData: clientPublicKeyData,
            request: request
        )
    }
    
    @Sendable
    private func signOut(with request: Request) async throws -> HTTPStatus {
        let accessTokenPayload = try request.auth.require(Payload.self)
        let accessToken = request.headers.bearerAuthorization!.token
        let refreshToken = request.headers.refreshToken
        
        guard let refreshToken else {
            try await UserService.revokeUserAccess(
                for: accessTokenPayload.subject.value,
                tokens: [accessToken: accessTokenPayload],
                at: request.db
            )
            
            return .ok
        }
        
        let refreshTokenPayload = try await request.jwt.verify(refreshToken, as: Payload.self)
        
        try await UserService.revokeUserAccess(
            for: accessTokenPayload.subject.value,
            tokens: [
                accessToken: accessTokenPayload,
                refreshToken: refreshTokenPayload
            ],
            at: request.db
        )
        
        return .ok
    }
}
