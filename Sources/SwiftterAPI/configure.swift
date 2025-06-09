import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // MARK: Database Configuration
    try DatabaseConfiguration.setDatabase(for: app)
    DatabaseConfiguration.setMigrations(for: app)
    
    try await app.autoMigrate()
    try await app.autoRevert()
    
    try await SlugCache.shared.populate(with: app.db)

    // MARK: JWT Configuration
    try await JWTConfiguration.setJWT(for: app)
    
    // register routes
    try routes(app)
}
