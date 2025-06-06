//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent

extension Topic {
    enum FieldName: String, FieldKeyProtocol {
        case topic = "topic"
        case counter = "counter"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        
        var key: FieldKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}
