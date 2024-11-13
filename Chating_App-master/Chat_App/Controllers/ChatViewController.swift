
import UIKit
import InputBarAccessoryView
import Firebase
import FirebaseStorage
import MessageKit
import FirebaseFirestore
import SDWebImage
import AVFoundation
import AVKit
import MobileCoreServices


class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    private var lastDocument: DocumentSnapshot? = nil
    private var isLoadingMessages = false
    
    let messageImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    var currentUser: chatUsers = chatUsers(senderId: "", displayName: "" , senderPhotoURL: "")
    
        var user2Name: String?
        var user2UID: String?
        var chatID: String? // Added chatID property
        var messages: [Message] = []
        private var docReference: DocumentReference?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = user2Name ?? "Chat"

        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true

        messageInputBar.inputTextView.tintColor = .systemBlue
        if let user2Name = user2Name {
            messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        } else {
            print("There is no user 2")
        }

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        
//        messagesCollectionView.register(CustomMessageCollectionViewCell.self)
        


        
        let imagePickerButton = InputBarButtonItem()
        imagePickerButton.tintColor = .systemGray
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
                imagePickerButton.image = UIImage(named: "img") // Set your image name
                imagePickerButton.setSize(CGSize(width: 36, height: 36), animated: false)
                imagePickerButton.addTarget(self, action: #selector(imagePickerButtonTapped), for: .touchUpInside)

                // Set up the left input stack view with the image picker button
                messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
                messageInputBar.setStackViewItems([imagePickerButton], forStack: .left, animated: false)
        
        if let currentUserID = Auth.auth().currentUser?.uid, let user2UID = user2UID {
                    chatID = [currentUserID, user2UID].sorted().joined(separator: "_")
            
            
        }
        
        // Add pull-to-refresh
        
        
       
        loadChat()
        // Add this to your viewDidLoad or where you set up your messagesCollectionView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        messagesCollectionView.refreshControl = refreshControl


    }
    
    
    @objc func loadMoreMessages() {
        print("123")
        guard let chatID = chatID, let lastDocument = lastDocument, !isLoadingMessages else {
            messagesCollectionView.refreshControl?.endRefreshing()
            return
        }

        isLoadingMessages = true

        let db = Firestore.firestore().collection("Chats").document(chatID)

        db.collection("thread")
            .order(by: "created", descending: false)
            .start(afterDocument: lastDocument)
            .limit(to: 20) // Adjust the limit as needed
            .getDocuments { [weak self] (threadQuery, error) in
                guard let self = self else { return }

                self.isLoadingMessages = false
                self.messagesCollectionView.refreshControl?.endRefreshing()

                if let error = error {
                    print("Error loading more messages: \(error)")
                    return
                }

                guard let documents = threadQuery?.documents, !documents.isEmpty else {
                    return
                }

                // Update lastDocument for the next pagination request
                self.lastDocument = documents.last

                // Parse and insert new messages
                let newMessages = documents.compactMap { Message(dictionary: $0.data()) }
                self.messages.insert(contentsOf: newMessages, at: 0)

                // Reload collection view
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
    }


    
    @objc func imagePickerButtonTapped(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }

 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         var selectedImagePicker : UIImage?
         
         if let editedImage = info[.editedImage] as? UIImage{
             selectedImagePicker = editedImage
         }
         else if let videoUrl = info[.mediaURL] as? URL {
             uploadVideoToFirebaseStorage(videoUrl: videoUrl)
         }
         else if let orignalImage = info[.originalImage] as? UIImage{
             selectedImagePicker = orignalImage
         }
         if let selectedImage = selectedImagePicker{
             uploadToFirebaseStorageUsingImage(image: selectedImage)
             
         }
         dismiss(animated: true, completion: nil)
     }


    
    private func uploadToFirebaseStorageUsingImage(image : UIImage){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messages_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2){
            ref.putData(uploadData , metadata: nil) { (metadata , error) in
                if error != nil {
                    print("Failed to Uplaod image" , error)
                    return
                }
//                Retrive the downlaod URL
                ref.downloadURL { (url, error) in
                    guard let downloadURL = url else{
                        print("Failed to get downlaod URL : ", error)
                        return
                    }
                    // Send the message with the image URL
                        self.sendMessagesWithUrl(imageUrl: downloadURL.absoluteString)

                }
            }
        }
    }
    private func sendMessagesWithUrl(imageUrl : String){
        guard let currentUser = Auth.auth().currentUser else {
                print("Error: Current user is nil.")
                return
            }

            // Create a Message object with the image URL
            let message = Message(
                id: UUID().uuidString,
                imageUrl: imageUrl,
                created: Timestamp(),
               messageSender: chatUsers(senderId: currentUser.uid, displayName: currentUser.displayName ?? "", senderPhotoURL: "")
            )

            // Save the message to Firebase
            save(message)
    }
    private func sendVideoMessageWithUrl(videoUrl: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: Current user is nil.")
            return
        }

        // Create a Message object with the video URL
        let message = Message(
            id: UUID().uuidString,
            videoUrl: videoUrl,
            created: Timestamp(),
            messageSender: chatUsers(senderId: currentUser.uid, displayName: currentUser.displayName ?? "", senderPhotoURL: "")
        )

        // Save the video message to Firestore
        save(message)
//        displayVideo(message: message)
        messagesCollectionView.reloadData()
    }
    
//    private func displayVideo(message: Message) {
//           guard let videoUrl = message.videoUrl else {
//               print("Error: Video URL is nil.")
//               return
//           }
//
//           // Download the video from the URL
//           let videoURL = URL(string: videoUrl)!
//           downloadVideo(videoURL: videoURL) { [weak self] (localVideoURL) in
//               guard let self = self, let localVideoURL = localVideoURL else {
//                   return
//               }
//
//               // Play the video
//               self.playVideo(videoURL: localVideoURL)
//           }
//       }
    
//    private func playVideo(videoURL: URL) {
//        DispatchQueue.main.async {
//            // Display video player
//            let player = AVPlayer(url: videoURL)
//            let playerViewController = AVPlayerViewController()
//            playerViewController.player = player
//
//            self.present(playerViewController, animated: true) {
//                player.play()
//            }
//        }
//    }

    
//    private func downloadVideo(videoURL: URL, completion: @escaping (URL?) -> Void) {
//         // Generate a local file URL to save the video
//         let localVideoURL = FileManager.default.temporaryDirectory.appendingPathComponent(videoURL.lastPathComponent)
//
//         // Download the video
//         URLSession.shared.downloadTask(with: videoURL) { (url, response, error) in
//             guard let url = url, error == nil else {
//                 print("Failed to download video: \(error?.localizedDescription ?? "Unknown error")")
//                 completion(nil)
//                 return
//             }
//
//             do {
//                 // Move the downloaded file to the local file URL
//                 try FileManager.default.moveItem(at: url, to: localVideoURL)
//                 completion(localVideoURL)
//             } catch {
//                 print("Error moving video file: \(error)")
//                 completion(nil)
//             }
//         }.resume()
//     }

    
    func uploadVideoToFirebaseStorage(videoUrl: URL) {
        // Extract the last path component (filename) from the URL
        let videoFilename = videoUrl.lastPathComponent

        // Now you can use videoFilename in your storage reference or other operations
        let videoName = NSUUID().uuidString + "_" + videoFilename
        let ref = Storage.storage().reference().child("messages_videos").child(videoName)

        // Compress the video before uploading
        compressVideo(videoUrl: videoUrl) { compressedURL in
            guard let compressedURL = compressedURL else {
                print("Error compressing the video.")
                return
            }

            do {
                // Convert compressed video file to Data
                let compressedVideoData = try Data(contentsOf: compressedURL)

                // Upload the compressed video data to Firebase Storage
                ref.putData(compressedVideoData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Failed to upload compressed video", error.localizedDescription)
                        if let errorCode = (error as NSError).userInfo[StorageErrorDomain] as? Int {
                            print("Storage error code:", errorCode)
                        }
                        return
                    }

                    // Retrieve the download URL for the video
                    ref.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print("Failed to get download URL for videos", error?.localizedDescription)
                            return
                        }

                        print("Download URL:", downloadURL.absoluteString)
                        // Send the message with video URL
                        self.sendVideoMessageWithUrl(videoUrl: downloadURL.absoluteString)
                        print("Video uploaded successfully!")
                    }
                }
            } catch {
                print("Error converting compressed video to Data:", error.localizedDescription)
            }
        }
    }

    // Function to compress the video
    func compressVideo(videoUrl: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: videoUrl)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(nil)
            return
        }

        // Use a temporary URL to save the compressed video
        let compressedURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")

        exportSession.outputFileType = .mp4
        exportSession.outputURL = compressedURL

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(compressedURL)
            case .failed, .cancelled:
                completion(nil)
            default:
                completion(nil)
            }
        }
    }


 func generateThumbnail(for videoURL: URL) -> UIImage? {
    let asset = AVAsset(url: videoURL)
    let imageGenerator = AVAssetImageGenerator(asset: asset)

    do {
        // Capture a frame at 1 second into the video
        let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
        let thumbnailImage = UIImage(cgImage: thumbnailCGImage)
        return thumbnailImage
    } catch {
        print("Error generating thumbnail: \(error)")
        return nil
    }
}
    func generateThumbnailURL(for videoURL: URL) -> URL? {
        guard let thumbnailImage = generateThumbnail(for: videoURL) else {
            return nil
        }

        // Save the thumbnail image to a temporary file
        guard let thumbnailURL = saveThumbnailToTemporaryFile(thumbnailImage) else {
            return nil
        }

        return thumbnailURL
    }


    func createNewChat() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: Current user is nil.")
            return
        }

        let users = [currentUser.uid, self.user2UID]
        let data: [String: Any] = [
            "users": users
        ]

        let db = Firestore.firestore().collection("Chats")
               db.document(chatID ?? "").setData(data) { (error) in
                   if let error = error {
                       print("Unable to create chat: \(error)")
                   } else {
                       self.loadChat()
                   }
               }
    }

    func loadChat() {
            guard let chatID = chatID else {
                print("Error: chatID is nil.")
                return
            }

            let db = Firestore.firestore().collection("Chats").document(chatID)

            db.getDocument { [weak self] (chatDocument, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error: \(error)")
                    return
                } else {
                    if let chatDocument = chatDocument, chatDocument.exists {
                        self.docReference = chatDocument.reference

                        chatDocument.reference.collection("thread").order(by: "created", descending: false).addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                            if let error = error {
                                print("Error: \(error)")
                                return
                            } else {
                                self.messages.removeAll()
                                 for message in threadQuery!.documents {
                                    print("FIerstore Data : \(message.data())")

                                    if let videoUrl = message["videoUrl"] as? String {
                                                                print("Video URL from Firestore: \(videoUrl)")
                                                            } else {
                                                                print("Video URL from Firestore is nil")
                                                            }
                                    var msg = Message(dictionary: message.data())
                                    self.messages.append(msg!)

                                    if let videoUrl = message["videoUrl"] as? String {
                                         msg?.videoUrl = videoUrl
                                     }


                                    print("Data: \(msg?.content ?? "No message found")")

                                    let senderID = message["senderID"] as? String ?? ""
                                    let senderName = message["senderName"] as? String ?? ""
                                    print("Sender ID: \(senderID), Sender Name: \(senderName)")
                                }
                                self.messagesCollectionView.reloadData()
                                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)

                            }
                        })
                    } else {
                        self.createNewChat()
                    }
                }
            }
        }




    private func insertNewMessage(_ message: Message) {
        messages.append(message)

        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }


    private func save(_ message: Message) {
        guard let user2UID = user2UID else {
            print("Error: User 2 UID is nil.")
            return
        }

        guard let currentUser = Auth.auth().currentUser else {
            print("Error: Current user is nil.")
            return
        }

        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": currentUser.uid, // Save the current user's UID
            "senderName": currentUser.displayName ?? "", // Save the current user's display name or an empty string if nil
            "imageUrl" : message.imageUrl, // Add imageUrl to the data
            "videoUrl" : message.videoUrl
        ]
        

        // Save the message under the user2 chat
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error sending: \(error)")
            } else {
                print("Message sent successfully!")
                
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        })
    }
  
    
   
    
    
    // Inside the configureMediaMessageImageView function
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        switch message.kind {
        case .photo(let media):
            // Use SDWebImage to load and set the image
            if let imageURL = media.url {
                imageView.sd_setImage(with: imageURL, completed: nil)
            }
        case .video(let media):
            // Download video and play it
            if let videoURL = media.url {
                
                let thumbnailImageURL = generateThumbnailURL(for: videoURL)
                imageView.sd_setImage(with: thumbnailImageURL, completed: nil)
                
            }
        default:
            // Cancel any ongoing download task
            imageView.sd_cancelCurrentImageLoad()
        }
    }
    func saveThumbnailToTemporaryFile(_ thumbnailImage: UIImage) -> URL? {
        do {
            // Save the thumbnail image to a temporary directory
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let thumbnailURL = temporaryDirectory.appendingPathComponent("thumbnail.jpg")
            let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.8)
            try thumbnailData?.write(to: thumbnailURL)
            return thumbnailURL
        } catch {
            print("Error saving thumbnail image: \(error)")
            return nil
        }
    }


    // InputBarAccessoryViewDelegate

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if currentUser.displayName != nil {
            let message = Message(id: UUID().uuidString, content: text, created: Timestamp(),messageSender: currentUser)

            // Message appending
            insertNewMessage(message)
            save(message)

            inputBar.inputTextView.text = ""
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem(animated: true)
        } else {
            // Handle the case where currentUser.displayName is nil
            print("Error: currentUser.displayName is nil")
        }
    }


    
//    MessagesLayoutDelegate
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return.zero
    }
    
//    MessagesDisplayDelegate
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(hex: 0x20A090) : UIColor(hex: 0xD3D3D3)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

            let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
            return .bubbleTail(corner, .curved)
        
        

        }
    
    // Before using user2, fetch the necessary information or create an instance
    let otherUser = chatUsers(senderId: "otherUserId", displayName: "OtherUserDisplayName", senderPhotoURL: "https://example.com/otherUserImage.jpg")


    // Now you can use otherUser in your configureAvatarView function
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let placeholderImage = UIImage(named: "default_avatar_image_name")

        if let currentUser = currentUser as? chatUsers, message.sender.senderId == currentUser.senderId {
            // Set avatar for the current user
            avatarView.sd_setImage(with: URL(string: currentUser.senderPhotoURL), completed: nil)

        } else if message.sender.senderId == otherUser.senderId {
            // Set avatar for the other user
            avatarView.sd_setImage(with: URL(string: otherUser.senderPhotoURL), completed: nil)
        }
    }





 
}
extension ChatViewController: MessagesDataSource {
    var currentSender: SenderType {
            if let currentUser = Auth.auth().currentUser {
                return chatUsers(senderId: currentUser.uid, displayName: currentUser.displayName ?? "Name not found", senderPhotoURL: "")
            } else {
                // Handle the case where currentUser is nil
                return chatUsers(senderId: "defaultSenderId", displayName: "Default User", senderPhotoURL: "")
            }
        }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

