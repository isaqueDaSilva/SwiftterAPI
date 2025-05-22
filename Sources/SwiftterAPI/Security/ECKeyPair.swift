//
//  ECKeyPair.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

/// An object that stores the id of the server private key and the server public key.
struct ECKeyPair: Content {
    /// An identifier of where the server's private key, is stored.
    let privateKeyID: UUID
    
    /// Data representation of server's public key.
    let publicKey: Data
}
