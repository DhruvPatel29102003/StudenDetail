//
//  MyTableViewCell.swift
//  studentDetail
//
//  Created by Droadmin on 6/26/23.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var nameLbl:UILabel!
    
    @IBOutlet weak var mobilLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        
        // Configure the view for the selected state
    }
    
}
