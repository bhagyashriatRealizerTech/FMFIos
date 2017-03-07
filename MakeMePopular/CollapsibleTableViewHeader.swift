//
//  CollapsibleTableViewHeader.swift
//  MakeMePopular
//
//  Created by Mac on 17/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//


import UIKit

protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(header: CollapsibleTableViewHeader, section: Int)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var friendImg: UIImageView!
    @IBOutlet weak var arrowLabel: UILabel!
    
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var accept: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.tapHeader(gestureRecognizer:))))
    }
    
    // Trigger toggle section when tapping on the header
    //
    func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func setCollapsed(collapsed: Bool) {
        //
        // Animate the arrow rotation (see Extensions.swf)
        //
        arrowLabel.rotate(toValue: collapsed ? 0.0 : CGFloat(M_PI_2))
    }
    
}


