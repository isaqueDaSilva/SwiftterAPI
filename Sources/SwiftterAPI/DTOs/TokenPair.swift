//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/26/25.
//

import Vapor

struct TokenPair: Content {
    let accessToken: Token
    let refreshToken: Token
    let publicKey: Data
}
