//
//  TimeLimit.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

extension Payload {
    enum TimeLimit: TimeInterval {
        case tenMinutes, sevenDays
        
        var rawValue: Double {
            switch self {
            case .tenMinutes:
                return (60 * 10)
            case .sevenDays:
                return (60 * 60 * 24 * 7)
            }
        }
    }
}
