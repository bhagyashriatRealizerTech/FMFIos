//
//  FriendListModel.swift
//  MakeMePopular
//
//  Created by Mac on 17/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import Foundation
import ObjectMapper


class FriendListModel: Mappable{
    
    var userId:String?
    var isTrackingAllowed:Bool?
    var isMessagingAllowed:Bool?
    var allowTrackingTillDate:String?
    var createTS:String?
    var trackingStatusChangeDate:String?
    var isEmergencyAlert:Bool?
    var friendsId:String?
    var friendName:String?
    var friendThumbnailUrl:String?
    var friendsUserId:String?
    var collapsed: Bool = true
    var isRequestSent:Bool?
    var status:String?
    var isDeleted:Bool?
    required init?(map: Map) {
        mapping(map: map)
    }
    
    
    func mapping(map: Map) {
        
        userId <- map["userId"]
        isTrackingAllowed <- map["isTrackingAllowed"]
        isMessagingAllowed <- map["isMessagingAllowed"]
        allowTrackingTillDate <- map["allowTrackingTillDate"]
        createTS <- map["createTS"]
        trackingStatusChangeDate <- map["trackingStatusChangeDate"]
        isEmergencyAlert <- map["isEmergencyAlert"]
        friendsId <- map["friendsId"]
        friendName <- map["friendName"]
        friendThumbnailUrl <- map["friendThumbnailUrl"]
        friendsUserId <- map["friendsUserId"]
        isRequestSent <- map["isRequestSent"]
        status <- map["status"]
        isDeleted <- map["isDeleted"]
    }
    init() {
        
    }
    
    
    func setupValue(friendName1:String, collapsed: Bool = true){
        friendName = friendName1
        self.collapsed = collapsed
    }
    
}
