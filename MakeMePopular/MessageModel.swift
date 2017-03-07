//
//  MessageModel.swift
//  MakeMePopular
//
//  Created by sachin shinde on 10/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import ObjectMapper



class MessageModel: Mappable {
    var messageId:String?
    var senderId:String?
    var timeStamp:String?
    var message:String?
    var threadId:String?
    var receiverId:String?
    var senderName:String?
    var senderThumbnail:String?
    var isRead:Bool?
    var isDeliver:Bool?
    var isSend:Bool=true
    
    required init?(map: Map) {
        
    }
    
    
    func mapping(map: Map) {
        
        messageId<-map["messageId"]
        senderId <- map["senderId"]
        timeStamp <- map["timeStamp"]
        message <- map["message"]
        threadId <- map["threadId"]
        receiverId <- map["receiverId"]
        senderName <- map["senderName"]
        
        isRead <- map["isRead"]
        isDeliver <- map["isDeliver"]
       isSend <- map["isSend"]
        
        print(senderName!)
        senderThumbnail <- map["senderThumbnail"]
        
    }
    init()
    {
        
    }
    
}
