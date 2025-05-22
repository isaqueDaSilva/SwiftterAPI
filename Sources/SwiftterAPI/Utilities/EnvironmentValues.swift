//
//  File.swift
//  SwifeetAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

enum EnvironmentValues {
    static func databaseURL() throws -> String {
        guard let databaseKey = Environment.get("DATABASE_URL") else {
            throw Abort(.internalServerError, reason: "Cannot possible to find the Database url.")
        }
        
        return databaseKey
    }
}
