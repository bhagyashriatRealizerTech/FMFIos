//
//  ThreadlistModel.swift
//  MakeMePopular
//
//  Created by sachin shinde on 10/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import ObjectMapper

class ThreadlistModel: Mappable {
    
    var threadId:String?
    var threadName:String?
    var thumbnailUrl:String?
    var lastSenderName:String?
    var badgeCount:String?
    var timeStamp:String?
    var lastSenderById:String?
    var lastMessageId:String?
    var lastMessageText:String?
    var initiateId:String?
    var initiateName:String?
    var threadCustomName:String?
    var participantList:String?
    
    
    required init?(map: Map) {
        
        
        
    }
    
    func mapping(map: Map) {
        threadId <- map["threadId"]
        threadName<-map["threadName"]
        thumbnailUrl <- map["thumbnailUrl"]
        lastSenderName <- map["lastSenderName"]
        badgeCount <- map["badgeCount"]
        timeStamp <- map["timeStamp"]
        lastSenderById<-map["lastSenderById"]
        lastMessageId<-map["lastMessageId"]
        lastMessageText <- map["lastMessageText"]
        initiateId <- map["initiateId"]
        initiateName<-map["initiateName"]
        threadCustomName <- map["threadCustomName"]
        participantList<-map["participantList"]
        print(participantList!)
        print(badgeCount!)
        
    }
    
    
    
}
