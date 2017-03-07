//
//  NearByFriendResponseModel.swift
//  MakeMePopular
//
//  Created by Mac on 23/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import ObjectMapper

class NearByFriendResponseModel:Mappable{
    
    var friendUserId:String?
    var friendName:String?
    var lastUpdatedOn:String?
    var thumbnailUrl:String?
    var distance:String?
    var distanceInKm:String?
    var duration:String?
    var latitude:Double?
    var longitude:Double?
    var age:Int?
    var gender:String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        friendUserId <- map["friendUserId"]
        friendName <- map["friendName"]
        lastUpdatedOn <- map["lastUpdatedOn"]
        thumbnailUrl <- map["thumbnailUrl"]
        distance <- map["distance"]
        distanceInKm <- map["distanceInKm"]
        duration <- map["duration"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        age <- map["age"]
        gender <- map["gender"]
    }
}



