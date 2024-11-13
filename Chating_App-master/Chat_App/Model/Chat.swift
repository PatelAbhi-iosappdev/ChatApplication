//
//  Chat.swift
//  Chat_App
//
//  Created by MACPC on 22/01/24.
//

import UIKit

struct Chat {
    var users : [String]
    var dictionary : [String : Any] {
        return ["users" : users]
    }
}

extension Chat{
    init?(dictionary : [String : Any]){
        guard let chatUsers = dictionary["users"] as? [String] else { return nil}
        self.init(users: chatUsers)
    }
}
