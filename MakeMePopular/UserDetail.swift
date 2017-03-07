//
//  UserDetail.swift
//  MakeMePopular
//
//  Created by sachin shinde on 11/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import Foundation
import ObjectMapper

class UserDetail: Mappable{
    
    var userId:String?
    var emailId:String?
    var fName:String?
    var lName:String?
    var contactNo:String?
    var dob:String?
    var gender:String?
    var accountType:String?
    var thumbnailUrl:String?
    var createTs:String?
    var isActive:Bool?
    var todayTrackedCount:String?
    var lastWeekTrackedCount:String?
    var lastMonthTrackedCount:String?
    var lastCity:String?
    var deviceId:String?
    var fcmRegId:String?
    var authToken:String?
    var FriendBadgeCount:String?
    var ChatBadgeCount:String?
    required init?(map: Map) {
        
    }
    
    
    func mapping(map: Map) {
        
        userId <- map["userId"]
        emailId <- map["emailId"]
        fName <- map["fName"]
        lName <- map["lName"]
        contactNo <- map["contactNo"]
        dob <- map["dob"]
        gender <- map["gender"]
        accountType <- map["accountType"]
        thumbnailUrl <- map["thumbnailUrl"]
        createTs <- map["createTs"]
        isActive <- map["isActive"]
        todayTrackedCount <- map["todayTrackedCount"]
        lastWeekTrackedCount <- map["lastWeekTrackedCount"]
        lastMonthTrackedCount <- map["lastMonthTrackedCount"]
        lastCity <- map["lastCity"]
        authToken <- map["authToken"]
        FriendBadgeCount <- map["FriendBadgeCount"]
        ChatBadgeCount<-map["ChatBadgeCount"]
        
    }
    init() {
        
    }
    
    func setupValue(email:String, fname:String, lname:String, contactno:String, dob:String, accountType:String, gender:String, thumbnailURL:String, createts:String, lastcity:String,devId:String, fcmregID:String){
    
        emailId = email
        fName = fname
        lName = lname
        contactNo = contactno
        self.dob = dob
        self.accountType = accountType
        self.gender = gender
        thumbnailUrl = thumbnailURL
        createTs = createts
        lastCity = lastcity
        deviceId = devId
        fcmRegId = fcmregID
        
    }
}
