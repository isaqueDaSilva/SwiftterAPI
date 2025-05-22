//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

struct HelperController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("public-key") { _ async throws -> ECKeyPair in
            try await CryptographyHandler.generatesPublicKey()
        }
    }
}
