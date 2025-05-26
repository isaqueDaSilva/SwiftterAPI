//
//  FieldName.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/25/25.
//


import Fluent

extension DisabledToken {
    enum FieldName: String, FieldKeyProtocol {
        case id = "id"
        case token = "token_value"
        case disabledAt = "disabled_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}