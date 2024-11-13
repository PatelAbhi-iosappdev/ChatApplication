//
//  ChatUsers.swift
//  Chat_App
//
//  Created by MACPC on 22/01/24.
//

import UIKit
import MessageKit

struct chatUsers : SenderType , Equatable {
    var senderId : String
    var displayName: String
    var senderPhotoURL: String // Add this property
}
