//
//  JWTSecretIdentifier.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/22/25.
//

import JWTKit

enum JWTSecretIdentifier: String {
    case accessTokenSecreyKey = "ACCESS_TOKEN_SECRET_KEY"
    case refreshTokenSecreyKey = "REFRESH_TOKEN_SECRET_KEY"
    
    var key: JWKIdentifier {
        .init(string: self.rawValue)
    }
}
