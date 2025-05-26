//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/22/25.
//

import Fluent
import JWT
import Vapor

enum JWTService {
    /// Creates a pair of JWTs tokens, one is the access token, and another for a encrypted representation of the refresh token.
    /// - Parameters:
    ///   - userID: The id of the user that is generating this token.
    ///   - userSlug: The slug of the profile of the user that is generating this token.
    ///   - clientPublicKeyData: The data representation of client's public key.
    ///   - request: The main request object that is responsible to perform the operation.
    /// - Returns: Returns a pair of JWT tokens, one is the access token,
    /// and another for a encrypted representation of the refresh token, along side of the server public key,
    /// used to encrypt the refresh token.
    static func createPairOfJWT(
        userID: UUID,
        userSlug: String,
        clientPublicKeyData: Data,
        request: Request
    ) async throws -> TokenPair {
        let serverPrivateKey = PrivateKey()
        let clientPublicKey = try PublicKey(rawRepresentation: clientPublicKeyData)
        
        let (accessToken, refreshToken) = try await Self.createTokens(
            with: userID,
            userSlug: userSlug,
            serverPrivateKey: serverPrivateKey,
            clientPublicKey: clientPublicKey,
            and: request
        )
        
        return .init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            publicKey: serverPrivateKey.rawRepresentation
        )
    }
    
    /// Creates a pair of JWT tokens, one for access and another for refresh the access token.
    /// - Parameters:
    ///   - userID: The id of the user that is generating this token.
    ///   - userSlug: The slug of the profile of the user that is generating this token.
    ///   - request: The main request object that is responsible to perform the operation.
    /// - Returns: Returns a base64 string representation of the access and refresh tokens.
    static private func createTokens(
        with userID: UUID,
        userSlug: String,
        serverPrivateKey: PrivateKey,
        clientPublicKey: PublicKey,
        and request: Request
    ) async throws -> (accessToken: Token, refreshToken: Token) {
        let accessPayload = try Payload(with: userID, userSlug: userSlug, audienceType: .fullAccess)
        let refreshPayload = try Payload(with: userID, userSlug: userSlug, audienceType: .refresh)
        
        async let accessToken = try request.jwt.sign(accessPayload, kid: JWTSecretIdentifier.accessTokenSecreyKey.key)
        async let refreshToken = try request.jwt.sign(refreshPayload, kid: JWTSecretIdentifier.refreshTokenSecreyKey.key)
        
        let tokens = try await [accessToken, refreshToken]
        
        guard tokens.count == 2 else {
            throw Abort(.notAcceptable, reason: "Error to generate tokens.")
        }
        
        let encryptedRefreshToken = try await Encryptor.encrypts(
            tokens[1].toData(),
            with: serverPrivateKey,
            and: clientPublicKey
        )
        
        return (
            .init(
                token: tokens[0],
                expirationTime: accessPayload.expiration.value
            ),
            .init(
                token: encryptedRefreshToken.base64EncodedString(),
                expirationTime: refreshPayload.expiration.value
            )
        )
    }
    
    /// Checks if the given Refresh Token is valid to flow with the action.
    /// - Parameters:
    ///   - tokenID: The id of the token, contained at `jti`
    ///   - tokenValue: The base64 raw value of the token, to check if it exist at the database.
    ///   - database: The database client representation to mediates the communication between the API and the Database system.
    /// - Returns: A boolean value that idicates if the token exists or not.
    static func isTokenValid(
        by tokenID: String,
        and tokenValue: String,
        on database: any Database
    ) async throws -> Bool {
        try await DisabledToken
            .query(on: database)
            .group(.or) { group in
                group
                    .filter(\.$id, .equal, tokenID)
                    .filter(\.$tokenValue, .equal, tokenValue)
            }
            .first() == nil
    }
    
    static func disableToken(with tokenID: String, tokenValue: String, on database: any Database) async throws {
        try await DisabledToken(tokenID: tokenID, tokenValue: tokenValue).create(on: database)
    }
    
    static func verifyClaimsAtPairOf(
        accessTokenPayload: Payload,
        refreshTokenPayload: Payload,
        at database: any Database
    ) async throws {
        guard accessTokenPayload.subject.value == refreshTokenPayload.subject.value,
              accessTokenPayload.userSlug == refreshTokenPayload.userSlug
        else {
            throw Abort(.unauthorized)
        }
        
        guard let userID = UUID(refreshTokenPayload.subject.value),
              let user = try await UserService.getUser(by: userID, at: database),
              try user.profile?.requireID() == refreshTokenPayload.userSlug
        else {
            throw Abort(.unauthorized)
        }
    }
}
