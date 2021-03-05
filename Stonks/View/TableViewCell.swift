//
//  FeedTableViewCell.swift
//  Stonks
//
//  Created by Maxim Perehod on 16.02.2021.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var stockImage: UIImageView!
    @IBOutlet var symbol: UILabel!
    @IBOutlet var fullName: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var change: UILabel!
    @IBOutlet var favButton: UIButton!
    @IBOutlet var roundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func favButton(_ sender: UIButton) {
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
