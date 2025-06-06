//
//  CreateSwifeet.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/4/25.
//

import Vapor

struct CreateSwifeet: Content {
    let body: String?
    let imageData: Data?
    let answerOf: String?
}

extension CreateSwifeet {
    func hasALeastOneContent() throws {
        guard self.body != nil || self.imageData != nil else {
            throw Abort(
                .notAcceptable,
                reason: "The Swifeet needs to has a least one content type to be valid."
            )
        }
    }
}
