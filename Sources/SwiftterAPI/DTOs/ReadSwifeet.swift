//
//  ReadSwifeet.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

import Vapor

struct ReadSwifeet: Content {
    let id: String
    let userSlug: String
    let body: String?
    let imageName: String?
    let answerOf: String?
    let answerCount: Int
    let likesCount: Int
    let createdAt: Date
}
