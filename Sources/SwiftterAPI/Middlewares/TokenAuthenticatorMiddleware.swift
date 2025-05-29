//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/26/25.
//

import Vapor

struct TokenAuthenticatorMiddleware: AsyncBearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let token = bearer.token
        
        let payload: Payload = if let decodedPayload = try? await request.jwt.verify(token, as: Payload.self) {
            decodedPayload
        } else {
            try await JWTService.disableToken(
                with: JWTService.makeUnknownID(),
                tokenValue: token,
                on: request.db
            )
            
            throw Abort(.unauthorized)
        }
        
        guard try await JWTService.isTokenValid(by: payload.jwtID.value, and: token, on: request.db),
              try await UserService.isUserInformationsValid(
                payload.subject.value,
                userSlug: payload.userSlug,
                on: request.db
              )
        else {
            try await JWTService.disableToken(with: payload.jwtID.value, tokenValue: token, on: request.db)
            throw Abort(.unauthorized)
        }
        
        request.auth.login(payload)
    }
}
