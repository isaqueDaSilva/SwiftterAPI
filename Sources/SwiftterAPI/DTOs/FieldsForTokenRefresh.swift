//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/25/25.
//

import Vapor

struct FieldsForTokenRefresh: Content {
    let accessToken: String
    let refreshToken: String
    let keyPair: KeyCollection
}
