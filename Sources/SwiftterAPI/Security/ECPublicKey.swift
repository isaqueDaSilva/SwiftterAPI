//
//  ECPublicKey.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

/// The representation object that stores the elliptic curve Server's public key.
struct ECPublicKey: Content {
    /// The identifier of where the server's private key, generated for that action, is stored.
    let id: UUID
    
    /// The generated server's public key.
    let publicKey: Data
}
