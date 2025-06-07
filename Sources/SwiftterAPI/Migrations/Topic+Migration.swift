//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import FluentPostgresDriver

extension Topic {
    struct Migration: AsyncMigration {
        private let schema = Topic.schema
        
        func prepare(on database: any Database) async throws {
            try await database.schema(schema)
                .field(
                    FieldName.id.key,
                    .uuid,
                    .identifier(auto: false),
                    .sql(.unique),
                    .required
                )
                .field(
                    FieldName.topic.key,
                    .string,
                    .required,
                    .sql(
                        .check(
                            SQLRaw(
                                "\(FieldName.topic.key) = LOWER(\(FieldName.topic.key))"
                            )
                        )
                    )
                )
                .field(
                    FieldName.counter.key,
                    .int,
                    .required,
                    .sql(.default(1))
                )
                .field(
                    FieldName.createdAt.key,
                    .date,
                    .required
                )
                .field(
                    FieldName.updatedAt.key,
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
