//
//  NearByFriendMainResModel.swift
//  MakeMePopular
//
//  Created by Mac on 20/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import ObjectMapper

class NearByFriendMainResModel:Mappable{
   
    var totalCount:Int?
    var totalPages:Int?
    var results:[NearByFriendResponseModel]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        totalCount <- map["totalCount"]
        totalPages <- map["totalPages"]
        results <- map["results"]
       
    }
    
    init() {
        
    }
}

