//
//  File.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

import Vapor

extension CreateUser: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add(
            Key.name.key,
            as: String.self,
            is: .count(2...),
            required: true,
            customFailureDescription: "The name is need to create a profile."
        )
        
        validations.add(
            Key.email.key,
            as: String.self,
            is: .email,
            required: true,
            customFailureDescription: "The email is need to be a valid one."
        )
        
        validations.add(
            Key.birthDate.key,
            as: Date.self,
            is: .custom(
                "Checks if the user has a least 13 years old",
                validationClosure: { validateBirthdate($0) }
            ),
            required: true,
            customFailureDescription: "You need to be a least 13 years old to subscribe in our plataform."
        )
    }
    
    
    
    /// Validated how many years the user has.
    /// - Parameter birthDate: user's birth date
    /// - Returns: Returs a boolean value indicating if the user has a least 13 years old.
    ///
    /// > Important: If the result was true, the user has more than 13 years old. If the result was false the user has less than 13 years old.
    private static func validateBirthdate(_ birthDate: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        
        if let age = ageComponents.year {
            return age >= 13
        }
        
        return false
    }
}
