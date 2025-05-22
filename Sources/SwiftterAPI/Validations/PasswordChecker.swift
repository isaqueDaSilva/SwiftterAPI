//
//  PasswordChecker.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/21/25.
//

/// A checker that verifies that the provided password complies with the minimum password strength standard.
///
/// To be valid, a password needs to be a least 8 characters, where, one of those characters needs to be a lowercase letter,
/// another a uppercase letter, a number and a special character.
enum PasswordChecker {
    /// A checker, to verifes if the given password flows the minimun requirements.
    /// - Parameter password: The user password.
    /// - Returns: Returns a boolean value, where when the value is true the password is valid,
    /// when the value is false, the password is not valid to continues.
    static func check(_ password: String) -> Bool {
        let regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s]).{8,}$/
        return password.wholeMatch(of: regex) != nil
    }
}
