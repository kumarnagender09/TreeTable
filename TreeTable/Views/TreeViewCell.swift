//
//  TreeViewCell.swift
//  TreeTable
//
//  Created by Nagender Kumar on 12/04/24.
//

import UIKit
class TreeViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var disclosureButton: UIButton?
    var disclosureButtonTapAction: (() -> Void)?
    
    override func layoutSubviews() {
           super.layoutSubviews()
           let indentationWidth = CGFloat(indentationLevel) * self.indentationWidth
           self.contentView.frame.origin.x = indentationWidth
       }
    @IBAction func disclosureButtonTapped(_ sender: Any) {
        disclosureButtonTapAction?()
    }
}

