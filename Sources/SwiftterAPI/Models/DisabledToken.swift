//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/25/25.
//

import Fluent
import Vapor

/// Representation table that is responsible to register disabled token to invalidate them and prevent some bad guy to access the API via disabled tokens
final class DisabledToken: Model, @unchecked Sendable {
    static let schema = "disabled_tokens"
    
    /// The id contained at the `jit` claim of the disabled token.
    @ID(custom: FieldName.tokenID.key, generatedBy: .user)
    var id: String?
    
    /// The raw base64 url value representation of the token.
    @Field(key: FieldName.tokenValue.key)
    var tokenValue: String
    
    /// The right time that the token lost your validity.
    @Field(key: FieldName.disabledAt.key)
    var disabledAt: Date
    
    init() { }
    
    init(tokenID: String, tokenValue: String) {
        self.id = tokenID
        self.tokenValue = tokenValue
        self.disabledAt = .now
    }
}
