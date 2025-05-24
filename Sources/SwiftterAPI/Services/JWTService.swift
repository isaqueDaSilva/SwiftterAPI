//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/22/25.
//

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
    ) async throws -> (accessToken: String, encryptedRefreshToken: Data, publicKey: Data) {
        let (accessToken, refreshToken) = try await Self.createTokens(with: userID, userSlug: userSlug, and: request)
        
        let refreshTokenData = try refreshToken.toData()
        
        let serverPrivateKey = PrivateKey()
        let clientPublicKey = try PublicKey(rawRepresentation: clientPublicKeyData)
        
        let encryptedRefreshToken = try await Encryptor.encrypts(refreshTokenData, with: serverPrivateKey, and: clientPublicKey)
        
        return (
            accessToken: accessToken,
            encryptedRefreshToken: encryptedRefreshToken,
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
        and request: Request
    ) async throws -> (accessToken: String, refreshToken: String) {
        let accessPayload = try Payload(with: userID, userSlug: userSlug, audienceType: .fullAccess)
        let refreshPayload = try Payload(with: userID, userSlug: userSlug, audienceType: .refresh)
        
        async let accessToken = try request.jwt.sign(accessPayload, kid: JWTSecretIdentifier.accessTokenSecreyKey.key)
        async let refreshToken = try request.jwt.sign(refreshPayload, kid: JWTSecretIdentifier.refreshTokenSecreyKey.key)
        
        let tokens = try await [accessToken, refreshToken]
        
        guard tokens.count == 2 else {
            throw Abort(.notAcceptable, reason: "Error to generate tokens.")
        }
        
        return (tokens[0], tokens[1])
    }
}
