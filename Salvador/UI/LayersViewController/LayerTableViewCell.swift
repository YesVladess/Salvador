/*
 *  LayerTableViewCell.swift
 *  Salvador
 *
 *  Created by Vlad Kononenko on 04.11.2023
 *  All rights reserved.
 *
 */

import UIKit

class LayerTableViewCell: UITableViewCell {

    @IBOutlet private weak var layerName: UILabel!
    
    func updateWith(model: LayerViewModel) {
        self.layerName.text = model.name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
