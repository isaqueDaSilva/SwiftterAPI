//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import FluentPostgresDriver

extension Like {
    struct Migration: AsyncMigration {
        private let schema = Like.schema
        private let swifeetSchema = Swifeet.schema
        private let userProfileSchema = UserProfile.schema
        private let profileSlug = UserProfile.FieldName.slug.key
        private let swifeetID = Swifeet.FieldName.id.key
        
        func prepare(on database: any Database) async throws {
            try await database.schema(schema)
                .field(
                    FieldName.id.key,
                    .string,
                    .identifier(auto: false),
                    .sql(
                        .check(
                            SQLRaw(
                                "\(FieldName.profileSlug.key) = CONCAT('LIKE-', \(FieldName.profileSlug.key), '-', \(FieldName.swifeetID.key))"
                            )
                        )
                    )
                )
                .field(
                    FieldName.profileSlug.key,
                    .string,
                    .references(
                        userProfileSchema,
                        profileSlug,
                        onDelete: .cascade
                    ),
                    .required
                )
                .field(
                    FieldName.swifeetID.key,
                    .string,
                    .references(
                        swifeetSchema,
                        swifeetID,
                        onDelete: .cascade
                    ),
                    .required
                )
                .field(
                    FieldName.likedAt.key,
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
