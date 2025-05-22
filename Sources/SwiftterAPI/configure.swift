import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // MARK: Database
    try DatabaseConfiguration.setDatabase(for: app)
    DatabaseConfiguration.setMigrations(for: app)

    try await app.autoMigrate()

    // register routes
    try routes(app)
}
