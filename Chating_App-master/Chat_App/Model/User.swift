//
//  User.swift
//  Chat_App
//
//  Created by MACPC on 23/01/24.
//

import UIKit

struct User {
    var uid: String
    var displayName: String
    var isChatAvailable: Bool

    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.displayName = dictionary["fullName"] as? String ?? ""
        self.isChatAvailable = false
    }
}

