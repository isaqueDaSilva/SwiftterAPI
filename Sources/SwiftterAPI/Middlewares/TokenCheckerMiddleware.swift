//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/26/25.
//

import Vapor

struct TokenCheckerMiddleware: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let token = bearer.token
        let payload = try await request.jwt.verify(token, as: Payload.self)
        
        guard try await JWTService.isTokenValid(by: payload.jwtID.value, and: token, on: request.db) else {
            try await JWTService.disableToken(with: payload.jwtID.value, tokenValue: token, on: request.db)
            throw Abort(.unauthorized)
        }
        
        guard let userID = UUID(uuidString: payload.subject.value) else {
            throw Abort(.unauthorized)
        }
        
        try await JWTService.verifyUserInformationsOnPayload(userID, userSlug: payload.userSlug, on: request.db)
        
        request.auth.login(payload)
    }
}
