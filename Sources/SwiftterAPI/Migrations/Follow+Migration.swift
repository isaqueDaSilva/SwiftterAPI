//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/31/25.
//

import Fluent
import FluentPostgresDriver

extension Follow {
    struct Migration: AsyncMigration {
        private let schema = Follow.schema
        private let userProfileSchema = UserProfile.schema
        private let userSlug = UserProfile.FieldName.slug.key
        
        func prepare(on database: any Database) async throws {
            try await database.schema(schema)
                .field(
                    FieldName.id.key,
                    .string,
                    .identifier(auto: false),
                    .sql(.unique),
                    .required
                )
                .field(
                    FieldName.follower.key,
                    .string,
                    .references(
                        userProfileSchema,
                        userSlug,
                        onDelete: .cascade
                    ),
                    .required
                )
                .field(
                    FieldName.following.key,
                    .string,
                    .references(
                        userProfileSchema,
                        userSlug,
                        onDelete: .cascade
                    ),
                    .required
                )
                .field(
                    FieldName.followedAt.key,
                    .date,
                    .required
                )
                .constraint(
                    .sql(
                        .check(
                            SQLRaw(
                                "\(FieldName.follower.rawValue) <> \(FieldName.following.rawValue)"
                            )
                        )
                    )
                )
                .create()
        }
        
        func revert(on database: any Database) async throws {
            // MARK: Implement this method when is need to revert something in this table...
        }
    }
}
