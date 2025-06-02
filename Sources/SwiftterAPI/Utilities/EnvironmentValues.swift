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
    
    static func swiftterJWTISSUER() throws -> String {
        guard let subjectClaim = Environment.get("JWT_ISSUER") else {
            print("SWIFTTER_JWTSUB was not found.")
            throw Abort(.internalServerError)
        }
        
        return subjectClaim
    }
    
    static func fullAccessJWTAudience() throws -> String {
        guard let jwtSecret = Environment.get("FULL_ACCESS_JWT_AUDIENCE") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func refreshJWTAudience() throws -> String {
        guard let jwtSecret = Environment.get("REFRESH_JWT_AUDIENCE") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func accessTokenSecret() throws -> String {
        guard let jwtSecret = Environment.get("ACCESS_TOKEN_SECRET") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func refreshTokenSecret() throws -> String {
        guard let jwtSecret = Environment.get("REFRESH_TOKEN_SECRET") else {
            throw Abort(.internalServerError)
        }
        
        return jwtSecret
    }
    
    static func profilePicturePath(with pictureName: String) throws -> String {
        guard let profilePictureFolder = Environment.get("PROFILE_PICTURE_FOLDER") else {
            throw Abort(.internalServerError)
        }
        
        return profilePictureFolder + "/" + pictureName
    }
    
    static func coverPicturePath(with pictureName: String) throws -> String {
        guard let profilePictureFolder = Environment.get("COVER_PICTURE_FOLDER") else {
            throw Abort(.internalServerError)
        }
        
        return profilePictureFolder + "/" + pictureName
    }
    
    static func swifeetPicturePath(with pictureName: String) throws -> String {
        guard let profilePictureFolder = Environment.get("SWIFEET_PICTURE_FOLDER") else {
            throw Abort(.internalServerError)
        }
        
        return profilePictureFolder + "/" + pictureName
    }
}
