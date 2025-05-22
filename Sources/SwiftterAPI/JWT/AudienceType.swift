//
//  AudienceType.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import JWTKit

extension Payload {
    enum AudienceType: String {
        case fullAccess = "0"
        case refresh = "1"
        
        func makeAudience() throws -> AudienceClaim {
            var audience = [self.rawValue]
            
            switch self {
            case .fullAccess:
                try audience.insert(EnvironmentValues.fullAccessJWTAudience(), at: 1)
            case .refresh:
                try audience.insert(EnvironmentValues.refreshJWTAudience(), at: 1)
            }
            
            return .init(value: audience)
        }
    }
}
