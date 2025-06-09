//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/9/25.
//

import Vapor

enum ExecutionError: Error {
    case notAcceptable
    case notFound
    case unauthorized
    case internalServerError
    
    func error(with description: String? = nil) -> Abort {
        switch self {
        case .notAcceptable:
            let description = description != nil ? description : "Not acceptable request."
            return Abort(.notAcceptable, reason: description)
        case .notFound:
            let description = description != nil ? description : "Item not found."
            return Abort(.notFound, reason: description)
        case .unauthorized:
            return Abort(.unauthorized, reason: description)
        case .internalServerError:
            return Abort(.internalServerError, reason: description)
        }
    }
}
