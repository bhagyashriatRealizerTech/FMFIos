//
//  NotificationCell.swift
//  MakeMePopular
//
//  Created by Mac on 03/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
  
    @IBOutlet weak var notifType: UITextView!
    @IBOutlet weak var notifDesc: UITextView!
    @IBOutlet weak var notifDate: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCell(notif:NotificationModel)
    {
        if(notif.notiType == "FriendRequestAccepted"){
            notifType.text = "Accepted"
        }
        else if(notif.notiType == "FriendRequestRejected"){
            notifType.text = "Rejected"
        }
        else if(notif.notiType == "FriendRequest"){
            notifType.text = "Friend Request"
        }
        else if(notif.notiType == "TrackingStarted"){
            notifType.text = "Tracking"
        }
        else if(notif.notiType == "EmergencyRecipt"){
            notifType.text = "Reciept"
        }
        else{
            notifType.text = notif.notiType
        }
        
        notifDesc.text = notif.notiText
        userName.text = notif.notiFromUserName
        
        userPic.layer.cornerRadius = 23
        userPic.clipsToBounds = true
        
        notifType.isUserInteractionEnabled = false
        notifDesc.isUserInteractionEnabled = false
        
        print("\(notif.notiTime)")
        let timeStampArr:[String] = (notif.notiTime?.components(separatedBy: "T"))!
        let dateArr:[String] = timeStampArr[0].components(separatedBy: "-")
        let startIndex = dateArr[0].index(dateArr[0].startIndex, offsetBy: 2)
        let dateStr = dateArr[2]+"/"+dateArr[1]+"/"+dateArr[0].substring(from: startIndex)
       
        notifDate.text = dateStr

        
        let v = userName.text
        let stArr = v?.components(separatedBy: " ")
        var st=""
        for s in stArr!{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        let imgText = ImageToText()
        userPic.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        if(notif.notiFromThumbnailUrl != nil){
            if(notif.notiFromThumbnailUrl != ""){
                let downloadImg = DownloadImage()
                downloadImg.setImage(imageurlString: notif.notiFromThumbnailUrl!, imageView: userPic)
            }
        }
     }
    
}
