//
//  SetLocationAPI.swift
//  MakeMePopular
//
//  Created by sachin shinde on 11/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import Foundation
import Alamofire
import GoogleMaps
import ObjectMapper

class SetLocationAPI{
    func setCoOrdinates(completed: DownloadComplete, coordinates:CLLocation, City:String){
        
        let methodName = "setUserCordinates"
        Current_Url = "\(TRACK_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        let parameters1 = ["userId":userId,"latitude":coordinates.coordinate.latitude,"longitude":coordinates.coordinate.longitude,"city":City] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json","Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
          
            let result = response.result
            let respo = response.response?.statusCode
            
            print("\(result.value)")
            
            if(respo == 200){
                
                let obj = Mapper<SetLocationResModel>().map(JSONObject: result.value)
                let pref = UserDefaults.standard
                
                pref.set(obj?.todaysTrackingCount?.stringValue, forKey: "TodayTrack")
                pref.set(obj?.lastWeekTrackingCount?.stringValue, forKey: "LastWeek")
                pref.set(obj?.lastMonthTrackingCount?.stringValue, forKey: "LastMonth")
                pref.set(obj?.FriendBadgeCount?.stringValue,forKey:"FriendCount")
                pref.set(obj?.ChatBadgeCount?.stringValue,forKey:"ChatCount")
                print("\(obj?.todaysTrackingCount)")
                print("\(UserDefaults.standard.value(forKey: "TodayTrack"))")

                pref.synchronize()
            }
            
        }
        
        completed()
    }

}
