import UIKit
import MessageKit

class CustomMessageCell: MessageContentCell {
    
    static var reuseIdentifier: String { return "customMessageCell" }
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override func setupSubviews() {
        addSubview(messageImageView)
        // Add constraints as needed for your layout
    }
}
