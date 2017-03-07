//
//  SearchFriendModel.swift
//  MakeMePopular
//
//  Created by Mac on 17/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import Foundation
import ObjectMapper


class SearchFriendModel: Mappable{
    
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
    var lastMonthTrackedCount:String?
    var lastCity:String?
    var deviceId:String?
    var interestName:String?
    var requestStatus:String?
    var age:Int?
    
    required init?(map: Map) {
        
        mapping(map: map)
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
        lastMonthTrackedCount <- map["lastMonthTrackedCount"]
        interestName <- map["interestName"]
        requestStatus <- map["requestStatus"]
        age <- map["age"]
        
    }
    init() {
        
    }
    func setupValue(fname:String, lname:String){
        fName = fname
        lName = lname
    }
    
}
