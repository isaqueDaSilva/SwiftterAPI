//
//  Migration.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent
import FluentPostgresDriver

extension User {
    struct Migration: AsyncMigration {
        let schemaName = User.schema
        
        func prepare(on database: any Database) async throws {
            try await database.schema(schemaName)
                .field(
                    FieldName.id.key,
                    .uuid,
                    .identifier(auto: false)
                )
                .field(
                    FieldName.name.key,
                    .string,
                    .required
                )
                .field(
                    FieldName.birthDate.key,
                    .date,
                    .required,
                    .sql(
                        .check(
                            SQLRaw(
                                "\(FieldName.birthDate.key) <= CURRENT_DATE - INTERVAL '13 years'" // Checks if the user has a least 13 years old.
                            )
                        )
                    )
                )
                .field(
                    FieldName.email.key,
                    .string,
                    .required,
                    .sql(.unique),
                    .sql(
                        .check(
                            SQLRaw(
                                "\(FieldName.email.key) LIKE '%@%_%.%_%'" // Checks if the given email is a valid one.
                            )
                        )
                    )
                )
                .field(
                    FieldName.passwordHash.key,
                    .string,
                    .required
                )
                .field(
                    FieldName.createdAt.key,
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
