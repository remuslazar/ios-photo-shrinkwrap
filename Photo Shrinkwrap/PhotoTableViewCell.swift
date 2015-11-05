//
//  PhotoTableViewCell.swift
//  Photo Shrinkwrap
//
//  Created by Remus Lazar on 03.11.15.
//  Copyright © 2015 Remus Lazar. All rights reserved.
//

import UIKit
import Photos

class PhotoTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var representedAssetIdentifier: String?
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var resolutionLabel: UILabel!
    @IBOutlet weak var filenameLabel: UILabel!

}
