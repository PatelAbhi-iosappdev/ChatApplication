// Message.swift

import UIKit
import Firebase
import MessageKit


struct Message {
    var id: String
    var content: String?
    var imageUrl : String?
    var videoUrl: String?
    var created: Timestamp
    var messageSender: chatUsers// Renamed from 'sender' to 'messageSender'
    var image: UIImage? 
    var dictionary: [String: Any] {
        return [
            "id": id,
            "content": content,
            "imageUrl": imageUrl,
            "VideoUrl" : videoUrl,
            "created": created,
            "senderID": messageSender.senderId,  // Updated property name
            "senderName": messageSender.displayName  // Updated property name
        ]
    }
}
public protocol MediaItemProtocol {
    var url: URL? { get }
    var image: UIImage? { get }
    var placeholderImage: UIImage { get }
    var size: CGSize { get }
}
struct MediaItem: MediaItemProtocol, MessageKit.MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(url: URL? = nil, image: UIImage? = nil, placeholderImage: UIImage, size: CGSize) {
        self.url = url
        self.image = image
        self.placeholderImage = placeholderImage
        self.size = size
    }
}
extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
//              let content = dictionary["content"] as? String,
              let created = dictionary["created"] as? Timestamp,
              let senderID = dictionary["senderID"] as? String,
              let senderName = dictionary["senderName"] as? String
        else {
            return nil
        }
        let content = dictionary["content"] as? String ?? ""
        let imageUrl = dictionary["imageUrl"] as? String
        let videoUrl = dictionary["videoUrl"] as? String
 
        print("Image URL1: \(imageUrl)")
        print("Video URL: \(videoUrl)")

        let sender = chatUsers(senderId: senderID, displayName: senderName, senderPhotoURL: imageUrl ?? "")
        

        self.init(id: id, content: content, imageUrl: imageUrl, videoUrl : videoUrl ,created: created, messageSender: sender)
            // Updated property name
    }
}



extension Message: MessageType {
    var messageId: String {
        return id
    }

    var sentDate: Date {
        return created.dateValue()
    }

    var kind: MessageKind {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            print("Photo")
            let mediaItem = MediaItem(url: url, image: nil, placeholderImage: UIImage(named: "placeholder_image_name") ?? UIImage(), size: CGSize(width: 200, height: 200))
            return .photo(mediaItem)
        } else {
            if let videoUrl = videoUrl {
                print("Video URL before trimming: \(videoUrl)")
                let trimmedVideoUrl = videoUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Trimmed Video URL: \(trimmedVideoUrl)")

                if !trimmedVideoUrl.isEmpty, let url = URL(string: trimmedVideoUrl) {
                    print("Valid videoUrl: \(trimmedVideoUrl)")

                    let mediaItem = MediaItem(url: url, image: nil, placeholderImage: UIImage(named: "placeholder_video_image_name") ?? UIImage(), size: CGSize(width: 200, height: 200))
                    return .video(mediaItem)
                } else {
                    print("Invalid or empty URL")
                    // Return a default message or handle the error accordingly
                    return .text("Invalid or empty video URL")
                }
            }
            else{
                print("Jayesh")
            }

            // Add a default return statement here
            return .text(content ?? "")
        }
    }

    var sender: SenderType {
        return messageSender  // Updated property name
    }
}

