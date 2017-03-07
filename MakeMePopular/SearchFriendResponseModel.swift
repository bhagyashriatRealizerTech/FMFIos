//
//  SearchFriendResponseModel.swift
//  MakeMePopular
//
//  Created by Mac on 18/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import Foundation
import ObjectMapper

class UserDetail: Mappable{
    
    var userId:String?
        required init?(map: Map) {
        
    }
    
    
    func mapping(map: Map) {
        
        userId <- map["userId"]
                
    }

}
