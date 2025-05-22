//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/22/25.
//

import Crypto
import Vapor

enum JWTConfiguration {
    static func setJWT(for application: Application) async throws {
        let accessTokenSecret = try EnvironmentValues.accessTokenSecret()
        let refreshTokenSecret = try EnvironmentValues.refreshTokenSecret()
        
        await application.jwt.keys.add(
            hmac: .init(stringLiteral: accessTokenSecret),
            digestAlgorithm: .sha512,
            kid: JWTSecretIdentifier.accessTokenSecreyKey.key
        )
        
        await application.jwt.keys.add(
            hmac: .init(stringLiteral: refreshTokenSecret),
            digestAlgorithm: .sha512,
            kid: JWTSecretIdentifier.refreshTokenSecreyKey.key
        )
    }
}
