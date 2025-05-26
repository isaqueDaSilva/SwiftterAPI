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
    let tokens: TokenPair
    let userProfile: Profile
    
    private init(tokenPair: TokenPair, userProfile: Profile) {
        self.tokens = tokenPair
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
        let tokenPair = try await JWTService.createPairOfJWT(
            userID: userID,
            userSlug: userProfile.requireID(),
            clientPublicKeyData: clientPublicKey,
            request: request
        )
        
        return try .init(
            tokenPair: tokenPair,
            userProfile: userProfile.toDTO()
        )
    }
}
