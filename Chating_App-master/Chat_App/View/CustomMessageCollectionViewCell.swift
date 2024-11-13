//import UIKit
//import MessageKit
//
//class CustomMessageCollectionViewCell: MessageContentCell {
//
//    static let reuseIdentifier = "customMessageCell"
//
//    let messageLabel: UILabel = {
//            let label = UILabel()
//            label.numberOfLines = 0
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }()
//
//
//    let messageImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 16
//        imageView.layer.masksToBounds = true
//        imageView.contentMode = .scaleAspectFill
//        imageView.isHidden = false
//        return imageView
//    }()
//
//    override init(frame: CGRect) {
//          super.init(frame: frame)
//          setupSubviews()
//      }
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupSubviews()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        // Reset any properties or views when the cell is reused.
//    }
//
//    override func setupSubviews(){
//        messageImageView.addSubview(messageLabel)
//        addSubview(messageImageView)
//
//        NSLayoutConstraint.activate([
//               messageImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//               messageImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//               messageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//               messageImageView.widthAnchor.constraint(equalToConstant: 200), // Adjust the width as needed
//
//               messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
//               messageLabel.leadingAnchor.constraint(equalTo: messageImageView.trailingAnchor, constant: 8), // Adjust the leading constraint to add space between image and label
//               messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//               messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//           ])
//        messageImageView.backgroundColor = .green
//            messageLabel.backgroundColor = .clear
//    }
//
//
//
//    func configure(with message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        print("Configure function called with kind: \(message.kind)")
//
//        switch message.kind {
//        case .text(let text):
//            // Handle text messages
//            print("Text Message: \(text)")
//
//            // Clear the image view as it's not needed for text messages
//            messageImageView.image = nil
//                 messageImageView.isHidden = true
//                 messageLabel.text = text
//
//            // Implement text message configuration here
//            messageLabel.text = text  // Assuming you have a messageLabel in your cell
//
//        case .photo(let mediaItem):
//            // Handle photo messages
//            if let imageUrl = mediaItem.url {
//                print("MediaItem URL: \(imageUrl)")
//                messageImageView.isHidden = false
//                messageImageView.loadImage(from: imageUrl) {
//                    print("Loaded")
//                }
//            } else {
//                print("MediaItem URL is nil")
//                messageImageView.isHidden = true
//            }
//
//        default:
//            print("Unsupported message type")
//            messageImageView.isHidden = true
//        }
//    }
//
//
//
//
//
//
//
//
//
//
//    class CustomMessagesCollectionViewFlowLayout : MessagesCollectionViewFlowLayout{
//        override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
//            return super.cellSizeCalculatorForItem(at: indexPath)
//        }
//    }
//
//}
//extension UIImageView {
//    func loadImage(from url: URL?, completion: (() -> Void)? = nil) {
//        guard let imageUrl = url else {
//            print("Image URL is nil")
//            completion?()
//            return
//        }
//
//        URLSession.shared.dataTask(with: imageUrl) { [weak self] (data, response, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("Error loading image: \(error)")
//                completion?()
//                return
//            }
//
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.image = image
//                }
//                completion?()
//            } else {
//                completion?()
//            }
//        }.resume()
//    }
//}
