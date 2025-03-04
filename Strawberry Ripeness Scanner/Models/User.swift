//
//  User.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/25/25.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let fullname: String
    let email: String
    var imagePaths: [String: String]
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Kenneth Pham", email: "test@gmail.com", imagePaths: [String: String]())
}
