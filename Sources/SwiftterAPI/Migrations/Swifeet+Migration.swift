//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Fluent
import FluentPostgresDriver

extension Swifeet {
    struct Migration: AsyncMigration {
        private let schema = Swifeet.schema
        private let userProfileSchema = UserProfile.schema
        private let userSlug = UserProfile.FieldName.slug.key
        
        func prepare(on database: any Database) async throws {
            try await database.schema(schema)
                .field(
                    FieldName.id.key,
                    .string,
                    .sql(.primaryKey(autoIncrement: false)),
                    .sql(.unique)
                )
                .field(
                    FieldName.profileSlug.key,
                    .string,
                    .references(
                        userProfileSchema,
                        userSlug,
                        onDelete: .setNull
                    ),
                    .required
                )
                .field(
                    FieldName.body.key,
                    .string
                )
                .field(
                    FieldName.imageName.key,
                    .string
                )
                .field(
                    FieldName.answerOf.key,
                    .string,
                    .references(
                        schema,
                        FieldName.id.key,
                        onDelete: .setNull
                    )
                )
                .field(
                    FieldName.answersCount.key,
                    .int,
                    .required,
                    .sql(.default(0)),
                    .sql(
                        .check(
                            SQLRaw("\(FieldName.answersCount.key) >= 0")
                        )
                    )
                )
                .field(
                    FieldName.likesCount.key,
                    .int,
                    .required,
                    .sql(.default(0)),
                    .sql(
                        .check(
                            SQLRaw("\(FieldName.likesCount.key) >= 0")
                        )
                    )
                )
                .field(
                    FieldName.createdAt.key,
                    .date,
                    .required
                )
                .constraint(
                    .sql(
                        .check(
                            SQLRaw("(\(FieldName.body.key) != NULL) OR (\(FieldName.imageName.key) != NULL)")
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
