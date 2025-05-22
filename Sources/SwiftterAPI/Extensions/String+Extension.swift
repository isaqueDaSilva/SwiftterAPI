// Original Source: https://www.hackingwithswift.com/example-code/strings/how-to-convert-a-string-to-a-safe-format-for-url-slugs-and-filename

import Vapor

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
