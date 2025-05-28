//
//  VerifyAndDisableTokensMiddleware.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/24/25.
//

import Fluent
import JWTKit
import Vapor

struct VerifyAndDisableTokensMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let fields = try request.content.decode(FieldsForTokenRefresh.self)
        
        let (accessPayload, refreshPayload) = try await self.getPayloads(
            for: fields.accessToken,
            and: fields.refreshToken,
            in: request
        )
        
        do {
            try await JWTService.verifyClaimsAtPairOf(
                accessTokenPayload: accessPayload,
                refreshTokenPayload: refreshPayload,
                at: request.db
            )
        } catch {
            try await JWTService.disableTokens(
                accessTokenID: accessPayload.jwtID.value,
                refreshTokenID: refreshPayload.jwtID.value,
                accessTokenValue: fields.accessToken,
                refreshTokenValue: fields.refreshToken,
                on: request.db
            )
            
            throw Abort(.unauthorized)
        }
        
        try await JWTService.disableTokens(
            accessTokenID: accessPayload.jwtID.value,
            refreshTokenID: refreshPayload.jwtID.value,
            accessTokenValue: fields.accessToken,
            refreshTokenValue: fields.refreshToken,
            on: request.db
        )
        
        request.auth.login(refreshPayload)
        
        try await request.cache.set(
            FieldsForTokenRefresh.storageKey,
            to: fields.publicKeyForEncryption,
            expiresIn: .minutes(2)
        )
        
        return try await next.respond(to: request)
    }
    
    private func getPayloads(
        for accessToken: String,
        and refreshToken: String,
        in request: Request
    ) async throws -> (accessTokenPayload: Payload, refreshTokenPayload: Payload) {
        async let accessTokenPayload = try JWTService.getPayload(on: accessToken.toData())
        async let refreshTokenPayload = try request.jwt.verify(refreshToken, as: Payload.self)
        
        do {
            let payloads = try await [accessTokenPayload, refreshTokenPayload]
            
            return (accessTokenPayload: payloads[0], refreshTokenPayload: payloads[1])
        } catch {
            let unknownAccessTokenID = JWTService.makeUnknownID()
            let unknownRefreshTokenID = JWTService.makeUnknownID()
            
            try await JWTService.disableTokens(
                accessTokenID: unknownAccessTokenID,
                refreshTokenID: unknownRefreshTokenID,
                accessTokenValue: accessToken,
                refreshTokenValue: refreshToken,
                on: request.db
            )
            
            throw Abort(.unauthorized)
        }
    }
}
