//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/30/25.
//

import NIOHTTP1

extension HTTPHeaders {
    var refreshToken: String? {
        self.first(name: "X-Refresh-Token")
    }
}
