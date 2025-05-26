//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/24/25.
//

import Vapor

struct Token: Content {
    let token: String
    let expirationTime: Date
}
