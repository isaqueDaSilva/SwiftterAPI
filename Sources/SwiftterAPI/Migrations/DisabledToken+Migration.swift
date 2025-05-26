//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/25/25.
//

import Fluent

extension DisabledToken {
    struct Migration: AsyncMigration {
        private let schema = DisabledToken.schema
        
        func prepare(on database: any Database) async throws {
            try await database.schema(schema)
                .field(
                    FieldName.tokenID.key,
                    .string,
                    .required,
                    .identifier(auto: false),
                    .sql(.unique)
                )
                .field(
                    FieldName.tokenValue.key,
                    .string,
                    .required,
                    .sql(.unique)
                )
                .field(
                    FieldName.disabledAt.key,
                    .date,
                    .required
                )
                .create()
            
        }
        
        func revert(on database: any Database) async throws {
            // MARK: Implement this method when is need to revert something in this table...
        }
    }
}
