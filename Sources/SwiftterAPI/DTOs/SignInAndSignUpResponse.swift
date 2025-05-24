//
//  SignInAndSignUpResponse.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//


import Vapor

typealias SignUpResponse = SignInAndSignUpResponse
typealias SignInResponse = SignInAndSignUpResponse

struct SignInAndSignUpResponse: Content {
    let accessToken: String
    let refreshToken: Data
    let serverPublicKey: Data
    let userProfile: Profile
    
    private init(accessToken: String, refreshToken: Data, serverPublicKey: Data, userProfile: Profile) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.serverPublicKey = serverPublicKey
        self.userProfile = userProfile
    }
}

extension SignInAndSignUpResponse {
    static func build(
        with userID: UUID,
        userProfile: UserProfile,
        clientPublicKey: Data,
        and request: Request
    ) async throws -> SignInAndSignUpResponse {
        let (accessToken, refreshToken, publicKey) = try await JWTService.createPairOfJWT(
            userID: userID,
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
