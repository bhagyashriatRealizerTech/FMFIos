//
//  FriendlistCell.swift
//  MakeMePopular
//
//  Created by Mac on 17/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Charts

class FriendlistCell: UITableViewCell {
    
    @IBOutlet weak var tracking: UILabel!
   
   
    @IBOutlet weak var unFriend: UILabel!
    
    @IBOutlet weak var block: UILabel!
    @IBOutlet weak var emergency: UILabel!
    
    @IBOutlet weak var emergencySwitch: UISwitch!
    
    @IBOutlet weak var blockImg: UIImageView!
    
    @IBOutlet weak var unFriendImg: UIImageView!
    @IBOutlet weak var trackImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCell(user:FriendListModel){
        let utils = Utils()
        var trackcolor = utils.hexStringToUIColor(hex: "7D898B")
       // var msgcolor = utils.hexStringToUIColor(hex: "7D898B")
        if(user.isTrackingAllowed == true){
            trackcolor = utils.hexStringToUIColor(hex: "5CDD67")
        }
       /* if(user.isMessagingAllowed == true){
            msgcolor = utils.hexStringToUIColor(hex: "5CDD67")
        }*/
        trackImg.image = UIImage.fontAwesomeIcon(name: .mapMarker, textColor: trackcolor, size: CGSize(width: 50, height: 50))
        
       
        if(user.status == "Blocked")
        {
        unFriendImg.image = UIImage.fontAwesomeIcon(name: .userTimes, textColor: utils.hexStringToUIColor(hex: "7D898B"), size: CGSize(width: 45, height: 45))
        
        blockImg.image = UIImage.fontAwesomeIcon(name: .timesCircle, textColor: utils.hexStringToUIColor(hex: "7D898B"), size: CGSize(width: 45, height: 45))
        }
       /* else if(user.status == "Unfriend")
        {
            unFriendImg.image = UIImage.fontAwesomeIcon(name: .userTimes, textColor: utils.hexStringToUIColor(hex: "7D898B"), size: CGSize(width: 45, height: 45))
            
            blockImg.image = UIImage.fontAwesomeIcon(name: .timesCircle, textColor: utils.hexStringToUIColor(hex: "DD2518"), size: CGSize(width: 45, height: 45))
        }*/
        else{
            unFriendImg.image = UIImage.fontAwesomeIcon(name: .userTimes, textColor: utils.hexStringToUIColor(hex: "FF6347"), size: CGSize(width: 45, height: 45))
            
            blockImg.image = UIImage.fontAwesomeIcon(name: .timesCircle, textColor: utils.hexStringToUIColor(hex: "DD2518"), size: CGSize(width: 45, height: 45))
        }
        
        
        if(user.isEmergencyAlert == true){
            emergencySwitch.isOn = true
        }
        else{
            emergencySwitch.isOn = false
        }
       
    }
}

