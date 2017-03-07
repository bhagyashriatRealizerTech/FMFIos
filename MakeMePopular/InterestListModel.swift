//
//  InterestListModel.swift
//  MakeMePopular
//
//  Created by Mac on 19/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import ObjectMapper

class InterestListModel:Mappable{
    
    var interestId:String?
    var interestName:String?
    var interestDesc:Bool?
    var isActive:Bool?
    var createTS:String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        interestId <- map["interestId"]
        interestName <- map["interestName"]
        interestDesc <- map["interestDesc"]
        isActive <- map["isActive"]
        createTS <- map["createTS"]
    }
}
