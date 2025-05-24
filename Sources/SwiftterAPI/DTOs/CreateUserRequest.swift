//
//  CreateUserRequest.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

struct CreateUserRequest {
    let name: String
    let email: String
    let birthDate: Date
    let password: Data
    let keyCollection: KeyCollection
}

extension CreateUserRequest {
    enum Key: String, CodingKey, ValidationKeyProtocol {
        case name, email, birthDate, password, keyCollection
        
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
        self.keyCollection = try container.decode(KeyCollection.self, forKey: .keyCollection)
    }
}
