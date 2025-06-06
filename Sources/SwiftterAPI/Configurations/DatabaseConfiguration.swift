//
//  DatabaseConfiguration.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//


import Fluent
import FluentPostgresDriver
import Vapor

enum DatabaseConfiguration {
    /// Sets the connection between the API and the database syatem.
    static func setDatabase(for application: Application) throws {
        let databaseKey = try EnvironmentValues.databaseURL()
        
        try application.databases.use(.postgres(url: databaseKey), as: .psql)
    }
    
    /// Sets all Migrations that is needed to configure tables on database..
    static func setMigrations(for application: Application) {
        application.migrations.add(User.Migration())
        application.migrations.add(UserProfile.Migration())
        application.migrations.add(Follow.Migration())
        application.migrations.add(DisabledToken.Migration())
        application.migrations.add(Swifeet.Migration())
        application.migrations.add(Like.Migration())
        application.migrations.add(Topic.Migration())
    }
}
