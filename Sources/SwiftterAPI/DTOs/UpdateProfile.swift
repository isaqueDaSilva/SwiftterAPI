//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/1/25.
//

import Vapor

struct UpdateProfile {
    let bio: String?
    let link: String?
}

extension UpdateProfile: Content {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.link = try container.decodeIfPresent(String.self, forKey: .link)
    }
    
    enum Key: String, CodingKey, ValidationKeyProtocol {
        case bio, link
        
        var key: ValidationKey {
            .init(stringLiteral: self.rawValue)
        }
    }
}
