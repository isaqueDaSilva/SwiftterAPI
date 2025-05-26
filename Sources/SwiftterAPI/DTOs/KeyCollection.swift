//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/23/25.
//

import Vapor

struct KeyCollection: Content {
    static let storageKey = "PUBLIC_KEY"
    
    let keyPairForDecryption: ECKeyPair
    let publicKeyForEncryption: Data
}
