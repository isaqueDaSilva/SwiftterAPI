//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/23/25.
//

import Vapor

protocol ProtectedRouteProtocol {
    func userProtectedRoute(with routes: any RoutesBuilder) -> any RoutesBuilder
    func tokenProtectedRoute(with routes: any RoutesBuilder) -> any RoutesBuilder
}

extension ProtectedRouteProtocol {
    func userProtectedRoute(with routes: any RoutesBuilder) -> any RoutesBuilder {
        let userAuthenticator = AuthenticatorMiddleware()
        let userGuardMiddleware = User.guardMiddleware(
            throwing: Abort(.unauthorized, reason: "User not authenticated")
        )
        
        return routes.grouped(userAuthenticator).grouped(userGuardMiddleware)
    }
    
    func tokenProtectedRoute(with routes: any RoutesBuilder) -> any RoutesBuilder {
        let tokenAuthenticator = TokenAuthenticatorMiddleware()
        let tokenGuardMiddleware = Payload.guardMiddleware(
            throwing: Abort(.unauthorized, reason: "Token not authenticated")
        )
        
        return routes.grouped(tokenAuthenticator).grouped(tokenGuardMiddleware)
    }
}
