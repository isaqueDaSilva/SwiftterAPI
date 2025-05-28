//
//  User+FieldName.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent

extension User {
    enum FieldName: String, FieldKeyProtocol {
        case id = "id"
        case name = "name"
        case birthDate = "birth_date"
        case email = "email"
        case passwordHash = "password_hash"
        case createdAt = "created_at"
        case isLogged = "ïs_logged"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}
