//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/1/25.
//

import Vapor

extension UpdateProfile: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add(
            Key.link.key,
            as: String.self,
            is: .custom(
                "Checks if the given url is valid.",
                validationClosure: { Self.checkLink($0) }
            ),
            required: false,
            customFailureDescription: "The name is need to create a profile."
        )
    }
}

extension UpdateProfile {
    /// Checks if the given link is valid.
    /// - Parameter link: The string representation of the given link.
    /// - Returns: Retuns a boolean value indicating if the link is valid or not
    private static func checkLink(_ link: String) -> Bool {
        let regex = /(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})/
        
        return !link.ranges(of: regex).isEmpty
    }
}
