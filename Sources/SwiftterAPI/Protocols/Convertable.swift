//
//  Convertable.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

protocol Convertable {
    associatedtype DTO: Content
    
    func toDTO() throws -> DTO
}

extension Array where Element: Convertable {
    func toDTOCollection() throws -> [Element.DTO] {
        try self.map({ try $0.toDTO() })
    }
}
