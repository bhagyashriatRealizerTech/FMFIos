//
//  DashboardCell.swift
//  MakeMePopular
//
//  Created by sachin shinde on 12/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
class DashboardCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var readbtn: UIButton!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCell(itemName:String,chatcount:String,frdcount:String){
        readbtn.isHidden=true
        readbtn.isEnabled=false
          readbtn.layer.cornerRadius = 10;
        let utils = Utils()
        utils.SetdashboardIcon(interest: itemName, txtColor: "ffffff", iconView: icon)
        if(itemName == "Friend Near"){
            name.text = "Near Me"
        }
        else if(itemName == "Invite Friend"){
            name.text = "Share App"
        }
        else if(itemName == "Friend List"){
            
            name.text = "Friends"
            readbtn.isHidden=true
            
            
            
            
            if(frdcount == "")
            {
                 readbtn.isHidden=true
                readbtn.isEnabled=false
               
            
            }
            else if(frdcount=="0"){
                readbtn.isHidden=true
                readbtn.isEnabled=false
            
            }
            else if(frdcount != "0"){
                readbtn.isHidden=false
                
                readbtn.layer.cornerRadius = 10;
             readbtn.titleLabel?.text=frdcount
                readbtn.setTitle(frdcount, for: .normal)

                
            }
          
        }
        
        else{
        name.text = itemName
            if(itemName=="Chat")
                {
                    readbtn.isHidden=true
                    if(chatcount != "0")
                    {
                        readbtn.isHidden=false
                        readbtn.titleLabel?.textColor=UIColor.white
                        readbtn.titleLabel?.text=chatcount
                        readbtn.setTitle(chatcount, for: .normal)
                        readbtn.layer.cornerRadius = 10;

                    }
                    else if(chatcount == "0"){
                        readbtn.isHidden=true
                        readbtn.isEnabled=true
                       // readbtn.layer.cornerRadius = 10;
                        
                    }

                }
          
        }
        
    }
}
