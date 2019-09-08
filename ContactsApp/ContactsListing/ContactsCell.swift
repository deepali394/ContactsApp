//
//  ContactsCell.swift
//  ContactsApp
//
//  Created by deepali on 07/09/19 at 9:29 PM.
//  Copyright © 2019 meditab. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {
    
    
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        contactImageView.layer.masksToBounds = false
        contactImageView.layer.cornerRadius = contactImageView.frame.height/2
        contactImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataForCell(data: ContactsModel) {
        
        contactNameLabel.text = (data.firstName ?? "") + (data.lastName ?? "")
        favoriteIcon.isHidden = data.favorite ?? false
        
        let url = URL(string: data.profilePic ?? "")
        let data = try? Data(contentsOf: url ?? URL(fileURLWithPath: ""))
        
        if let imageData = data {
            let image = UIImage(data: imageData)
            contactImageView.image = image
        }
    }

}
