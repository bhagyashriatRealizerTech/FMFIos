//
//  NotificationModel.swift
//  MakeMePopular
//
//  Created by Mac on 03/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import ObjectMapper

class NotificationModel:Mappable{
    
    var notificationId:String?
    var notiFromUserId:String?
    var notiFromUserName:String?
    var notiFromThumbnailUrl:String?
    var notiToUserId:String?
    var notiText:String?
    var notiTime:String?
    var notiType:String?
    var isReceived:Bool?
    var isRead:Bool?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        notificationId <- map["notificationId"]
        notiFromUserId <- map["notiFromUserId"]
        notiFromUserName <- map["notiFromUserName"]
        notiFromThumbnailUrl <- map["notiFromThumbnailUrl"]
        notiToUserId <- map["notiToUserId"]
        notiText <- map["notiText"]
        notiTime <- map["notiTime"]
        notiType <- map["notiType"]
        isReceived <- map["isReceived"]
        isRead <- map["isRead"]
    }
}


