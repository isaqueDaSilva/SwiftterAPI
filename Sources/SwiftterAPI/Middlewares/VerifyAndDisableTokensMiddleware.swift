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
        let sharedKey = try await SharedKeyMaker.makeSharedKey(with: fields.keyPair.keyPairForDecryption)
        let decryptedRefreshToken = try CryptographyHandler.decryptField(
            encryptedField: fields.refreshToken.toData(),
            key: sharedKey
        )
        
        guard let decryptedRefreshToken else {
            let tokenID = try self.getPayload(on: fields.accessToken.toData()).jwtID.value
            try await self.disableToken(with: tokenID, rawValue: fields.accessToken, at: request.db)
            
            throw Abort(.unauthorized)
        }
        
        let (accessPayload, refreshPayload) = try await self.getPayloads(
            for: fields.accessToken,
            and: decryptedRefreshToken
        )
        
        try await JWTService.verifyClaimsAtPairOf(
            accessTokenPayload: accessPayload,
            refreshTokenPayload: refreshPayload,
            at: request.db
        )
        
        try await self.disableTokens(
            accessTokenID: accessPayload.jwtID.value,
            refreshTokenID: refreshPayload.jwtID.value,
            accessTokenValue: fields.accessToken,
            refreshTokenValue: decryptedRefreshToken,
            on: request.db
        )
        
        request.auth.login(refreshPayload)
        try await request.cache.set(KeyCollection.storageKey, to: fields.keyPair.publicKeyForEncryption, expiresIn: .minutes(2))
        
        return try await next.respond(to: request)
    }
    
    private func getPayload(on token: Data) throws -> Payload {
        let (_, payload, _) = try DefaultJWTParser().parse(token, as: Payload.self)
        
        return payload
    }
    
    private func getPayloads(
        for accessToken: String,
        and refreshToken: String
    ) async throws -> (accessTokenPayload: Payload, refreshTokenPayload: Payload) {
        async let accessTokenPayload = try self.getPayload(on: accessToken.toData())
        async let refreshTokenPayload = try self.getPayload(on: refreshToken.toData())
        
        let payloads = try await [accessTokenPayload, refreshTokenPayload]
        
        return (accessTokenPayload: payloads[0], refreshTokenPayload: payloads[1])
    }
    
    private func disableToken(with id: String, rawValue: String, at database: any Database) async throws {
        try await JWTService.disableToken(
            with: id,
            tokenValue: rawValue,
            on: database
        )
    }
    
    private func disableTokens(
        accessTokenID: String,
        refreshTokenID: String,
        accessTokenValue: String,
        refreshTokenValue: String,
        on database: any Database
    ) async throws {
        try await withThrowingTaskGroup { group in
            _ = group.addTaskUnlessCancelled {
                try await self.disableToken(
                    with: accessTokenID,
                    rawValue: accessTokenValue,
                    at: database
                )
            }
            
            _ = group.addTaskUnlessCancelled {
                try await self.disableToken(
                    with: refreshTokenID,
                    rawValue: refreshTokenValue,
                    at: database
                )
            }
            
            guard try await group.next() != nil else {
                group.cancelAll()
                return
            }
        }
    }
}
