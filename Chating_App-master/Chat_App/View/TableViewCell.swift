//
//  TableViewCell.swift
//  Chat_App
//
//  Created by MACPC on 23/01/24.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var uid: UILabel!
    @IBOutlet var username: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
