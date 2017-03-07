//
//  NearByPlacesModel.swift
//  MakeMePopular
//
//  Created by Mac on 01/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import Foundation

class NearByPlacesModel{
    
    var name:String = ""
    var isOpen:Bool = false
    var lat:Double = 0
    var lang:Double = 0
    var address:String = ""
    
    init(Name:String, IsOpen:Bool, Lat:Double, Lang:Double, Address:String) {
        name = Name
        isOpen = IsOpen
        lat = Lat
        lang = Lang
        address = Address
    }
    
}
