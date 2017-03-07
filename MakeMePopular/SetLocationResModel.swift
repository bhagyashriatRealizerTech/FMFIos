//
//  SetLocationResModel.swift
//  MakeMePopular
//
//  Created by Mac on 02/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import ObjectMapper

class SetLocationResModel:Mappable{
    var success:String?
    var todaysTrackingCount:NSNumber?
    var lastWeekTrackingCount:NSNumber?
    var lastMonthTrackingCount:NSNumber?
    var FriendBadgeCount:NSNumber?
    var ChatBadgeCount:NSNumber?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        // friendUserId <- map["friendUserId"]
        success <- map["success"]
        todaysTrackingCount <- map["todaysTrackingCount"]
        lastWeekTrackingCount <- map["lastWeekTrackingCount"]
        lastMonthTrackingCount <- map["lastMonthTrackingCount"]
        FriendBadgeCount <- map["FriendBadgeCount"]
        ChatBadgeCount <- map["ChatBadgeCount"]
    }
}

