//
//  CreateUserRequest.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

/// The representation of the DTO object that will be used to decode a JSON object,
/// coming from the request, with the users informations to create their account.
struct CreateUserRequest {
    let name: String
    let email: String
    let birthDate: Date
    let password: Data
    let publicKeyForPassword: ECKeyPair
    let publicKeyForToken: Data
}

extension CreateUserRequest {
    enum Key: String, CodingKey, ValidationKeyProtocol {
        case name, email, birthDate, password, publicKeyForPassword, publicKeyForToken
        
        var key: ValidationKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}

extension CreateUserRequest: Content {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
        self.birthDate = try container.decode(Date.self, forKey: .birthDate)
        self.password = try container.decode(Data.self, forKey: .password)
        self.publicKeyForPassword = try container.decode(ECKeyPair.self, forKey: .publicKeyForPassword)
        self.publicKeyForToken = try container.decode(Data.self, forKey: .publicKeyForToken)
    }
}
