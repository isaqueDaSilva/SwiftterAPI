//
//  Profile.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

struct Profile: Content {
    let slug: String
    let profilePictureName: String
    let coverImageName: String
    let bio: String?
    let link: String?
    let followersCount: Int
    let followingCount: Int
    let swifeetCount: Int
    let createdAt: Date
}
