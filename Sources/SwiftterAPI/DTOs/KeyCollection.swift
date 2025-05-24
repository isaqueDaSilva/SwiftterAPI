//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/23/25.
//

import Vapor

struct KeyCollection: Content {
    let keyPairForPassword: ECKeyPair
    let publicKeyForToken: Data
}
