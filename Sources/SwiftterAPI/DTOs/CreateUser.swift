//
//  CreateUser.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

/// The representation of the DTO object that will be used to decode a JSON object,
/// coming from the request, with the users informations to create their account.
struct CreateUser {
    let name: String
    let email: String
    let birthDate: Date
    let password: Data
    let publicKey: ECPublicKey
}

extension CreateUser {
    enum Key: String, CodingKey, ValidationKeyProtocol {
        case name, email, birthDate, password, publicKey
        
        var key: ValidationKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}

extension CreateUser: Content {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.birthDate = try container.decode(Date.self, forKey: .birthDate)
        self.password = try container.decode(Data.self, forKey: .password)
        self.publicKey = try container.decode(ECPublicKey.self, forKey: .publicKey)
    }
}
