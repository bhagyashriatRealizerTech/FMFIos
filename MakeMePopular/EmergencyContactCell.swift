//
//  EmergencyContactCell.swift
//  MakeMePopular
//
//  Created by Mac on 20/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Charts

class EmergencyContactCell: UITableViewCell {
    
    
    @IBOutlet weak var recieptImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCell(user:FriendListModel){
       // let utils = Utils()
        username.text = user.friendName!
        
            //recieptImg.image = UIImage.fontAwesomeIcon(name: .tic, textColor: utils.hexStringToUIColor(hex: "0097A7"), size: CGSize(width: 35, height: 35))
        
        let v = username.text
        let stArr = v?.components(separatedBy: " ")
        var st=""
        for s in stArr!{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        profilePic.layer.cornerRadius = 22
        profilePic.clipsToBounds = true
        
        let imgText = ImageToText()
        profilePic.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        if(user.friendThumbnailUrl != nil){
            if(user.friendThumbnailUrl != ""){
              let downloadImg = DownloadImage()
              downloadImg.setImage(imageurlString: user.friendThumbnailUrl!, imageView: profilePic)
            }
        }

    }
}
