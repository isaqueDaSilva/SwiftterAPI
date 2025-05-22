import Fluent
import Vapor

func routes(_ app: Application) throws {
    let apiRoute = app.routes.grouped("api")
    
    apiRoute.get { req async in
        "It works!"
    }

    apiRoute.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    try apiRoute.register(collection: AuthController())
    try apiRoute.register(collection: HelperController())
    
    print(app.routes)
}
