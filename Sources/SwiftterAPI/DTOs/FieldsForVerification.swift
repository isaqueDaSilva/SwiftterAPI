//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/25/25.
//

import Vapor

struct FieldsForTokenRefresh: Content {
    static let storageKey = "PUBLIC_KEY"
    
    let accessToken: String
    let refreshToken: String
    let publicKeyForEncryption: Data
}
