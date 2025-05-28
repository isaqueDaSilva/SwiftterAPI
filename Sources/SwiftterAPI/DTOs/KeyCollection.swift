//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/23/25.
//

import Vapor

struct KeyCollection: Content {
    let keyPairForDecryption: ECKeyPair
    let publicKeyForEncryption: Data
}
