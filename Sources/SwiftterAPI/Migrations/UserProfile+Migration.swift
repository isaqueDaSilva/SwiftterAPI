//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Fluent
import FluentPostgresDriver

extension UserProfile {
    struct Migration: AsyncMigration {
        let schema = UserProfile.schema
        let userSchema = User.schema
        
        func prepare(on database: any Database) async throws {
            try await database.schema(schema)
                .field(
                    FieldName.slug.key,
                    .string,
                    .identifier(auto: false),
                    .sql(.unique)
                )
                .field(
                    FieldName.userID.key,
                    .uuid,
                    .references(
                        userSchema,
                        "id",
                        onDelete: .cascade
                    ),
                    .sql(.unique)
                )
                .field(
                    FieldName.profilePictureName.key,
                    .string,
                    .sql(.default(UserProfile.defaultImageName))
                )
                .field(
                    FieldName.coverImageName.key,
                    .string,
                    .sql(.default(UserProfile.defaultImageName))
                )
                .field(
                    FieldName.bio.key,
                    .string
                )
                .field(
                    FieldName.link.key,
                    .string
                )
                .field(
                    FieldName.followersCount.key,
                    .int,
                    .required,
                    .sql(.default(0)),
                    .sql(
                        .check(
                            SQLRaw("\(FieldName.followersCount.key) >= 0")
                        )
                    )
                )
                .field(
                    FieldName.followingCount.key,
                    .int,
                    .required,
                    .sql(.default(0)),
                    .sql(
                        .check(
                            SQLRaw("\(FieldName.followingCount.key) >= 0")
                        )
                    )
                )
                .field(
                    FieldName.swifeetCount.key,
                    .int,
                    .required,
                    .sql(.default(0)),
                    .sql(
                        .check(
                            SQLRaw("\(FieldName.swifeetCount.key) >= 0")
                        )
                    )
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
