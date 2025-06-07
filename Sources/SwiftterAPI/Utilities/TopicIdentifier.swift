//
//  TopicIdentifier.swift
//  SwiftterAPI
//
//  Created by Isaque da Silva on 6/6/25.
//

enum TopicIdentifier {
    static func identify(at swifeetBody: String) -> [String] {
        let regex = /#[\p{L}\d_]{2,}/
        let topics = swifeetBody.matches(of: regex)
        
        return topics.map( { String($0.output) })
    }
}
