//
//  String+Extension.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 5/23/25.
//

import Vapor

// MARK: - Original Source: https://www.hackingwithswift.com/example-code/strings/how-to-convert-a-string-to-a-safe-format-for-url-slugs-and-filename -

// MARK: Slug generator

extension String {
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")

    func convertedToSlug() -> String? {
        if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            let urlComponents = latin.components(separatedBy: String.slugSafeCharacters.inverted)
            let result = urlComponents.filter { $0 != "" }.joined(separator: "-")

            if result.count > 0 {
                return result
            }
        }

        return nil
    }
    
    func isSlug() -> Bool {
        guard let regex = try? Regex("^[a-z0-9]+(?:-[a-z0-9]+)*$") else {
            fatalError("The REGEX is not valid.")
        }
        
        return self.wholeMatch(of: regex) != nil
    }
}

// MARK: - My code -

extension String {
    /// Transform a base64 string representation into a binary data type.
    /// - Returns: Returns a binary data representation of the given base64 string.
    func toData() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw Abort(.notAcceptable)
        }
        
        return data
    }
}
