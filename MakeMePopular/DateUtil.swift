//
//  DateUtil.swift
//  MakeMePopular
//
//  Created by sachin shinde on 08/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//


import Foundation
class DateUtil{
    
    func  getDayOfWeek( day:Int)-> String {
        var dayOfWeek:String = "";
        
        switch (day) {
        case 1:
            dayOfWeek = "Sunday";
            break;
        case 2:
            dayOfWeek = "Monday";
            break;
        case 3:
            dayOfWeek = "Tuesday";
            break;
        case 4:
            dayOfWeek = "Wednesday";
            break;
        case 5:
            dayOfWeek = "Thursday";
            break;
        case 6:
            dayOfWeek = "Friday";
            break;
        case 7:
            dayOfWeek = "Saturday";
            break;
            
        default:
            break
            
        }
        
        return dayOfWeek;
    }
    
    func getLocalDate(utcDate:String) -> String{
        let tempDate:String = utcDate.components(separatedBy: ".")[0]
        var localDate:String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let date = dateFormatter.date(from: tempDate)// 
        
        dateFormatter.dateFormat = "dd/MM/yyyy h:mm a"
        dateFormatter.timeZone = TimeZone.current
        if(date != nil)
        {
            localDate = dateFormatter.string(from: date!)
        }
        return localDate
    }
    
    func getDate(date:String , FLAG: String,t:String) ->String{
        if(date == "")
        {
            return ""
        }
        var datetimevalue:String = ""
        var  resultString :String=""
       
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        let d = dateformatter.date(from: date)
      
        var outdate:String!
        let currentdate:String=dateformatter.string(from: Date())
        let  dateformatter1 = DateFormatter()
        dateformatter1.dateFormat = "dd  MMM yyyy"
        if(d != nil)
        {
          
         
           
        
            outdate = dateformatter.string(from: d!)
         
            
        }
        else{
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let showDate = inputFormatter.date(from: t)
            if(showDate != nil)
            {
                resultString = outputFormatter.string(from: showDate!)
                outdate=dateformatter.string(from: showDate!)
                
            }
            
            print(resultString)
            
            
        }
        
        
        var outtime: String = ""
       
        if(date.components(separatedBy: "").count>0) {
            var E1:String=""
            var time:[String]=[]
            if(t.contains("T"))
            {
                time = t.components(separatedBy: "T")[1].components(separatedBy: ":")
              
            }
            else{
               // let c1=t.components(separatedBy: " ").count
              
                time = t.components(separatedBy: " ")[1].components(separatedBy: ":")
//            
//                if(c1==2)
//                {
//                    if(t.components(separatedBy: " ")[1] != "")                    {
//                    time = t.components(separatedBy: " ")[1].components(separatedBy: ":")
//                        
//                    }
//                }
//                if(t.components(separatedBy: " ")[c1-1] != "")
//                {
//                    E1=t.components(separatedBy: " ")[c1-1].components(separatedBy: ":")[0]
//                }
//                
            }
            
            let p=time[0]
            var tp:String = ""
         
            let t=Int(p)
            var t1:Int!
         
            
            if((t! as Int) != 0 )
            {
            t1=(t! as Int)
            }
           
            if (t1==12)
            {
                tp = "PM";
              
                           
                outtime = String(describing: t1! as Int) + ":" + time[1] + " " + tp;
            }
            else if (t1 > 12) {
                let t2:Int = t1 - 12;
                if(E1=="")
                {
                    E1 = "PM";
                }
                
                
                E1="PM"
                outtime = String(t2) + ":" + time[1] + " " + E1;
            } else {
                if(E1=="")
                {
                    E1 = "AM";
                    
                }
               // E1 = "AM";
                
                
                outtime = time[0] + ":" + time[1] + " " + E1;

            }
        }
       
        if (FLAG=="D" || FLAG=="DT") {
            
            //Current Date Message
            if (outdate == currentdate && outdate != "") {
                datetimevalue = outtime//"Today"
                               
            } else {
                let cal=NSCalendar.current
                let oneDayAgo = cal.date(byAdding: .day, value: -1, to: Date())
                let d1 = dateformatter.string(from: oneDayAgo!)
               
                if (outdate == d1) {
                    datetimevalue = "Yesterday";
                    
                } else {
                    var twodaysAgo = cal.date(byAdding: .day, value: -2, to: Date())
                    var daysago = dateformatter.string(from: twodaysAgo!)
                    
                    
                   
                    
                    
                    var count = -3
                    for i in 0...5
                    {
                        if (outdate == daysago) {
                            let day:Int = cal.component(.weekday, from: twodaysAgo!)
                            datetimevalue = getDayOfWeek(day: day)
                            break
                        }
                        else{
                            if (i == 4) {
                                if(d != nil){
                                    datetimevalue = dateformatter1.string(from: d!)
                                }
                                else{
                                    
                                    datetimevalue = t
                                }
                                
                                
                            } else
                            {
                                twodaysAgo = cal.date(byAdding: .day, value: count, to: Date())
                                daysago = dateformatter.string(from: twodaysAgo!)
                                count  = count-1
                            }
                        }
                        
                    }
                }
                
                if (FLAG == "DT")
                {
                    datetimevalue = datetimevalue + " " + outtime
                }
                else {
                    if(FLAG == "T"){
                        datetimevalue = outtime
                    }
                    
                }
                
            }
        }
        return datetimevalue;
    }
    
    
    func getDateforday(date:String , FLAG: String,t:String) ->String{
        if(date == "")
        {
            return ""
        }
        var datetimevalue:String = ""
        var  resultString :String=""
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        let d = dateformatter.date(from: date)
        
        var outdate:String!
        let currentdate:String=dateformatter.string(from: Date())
        let  dateformatter1 = DateFormatter()
        dateformatter1.dateFormat = "dd  MMM yyyy"
        if(d != nil)
        {
            
            
            
            
            outdate = dateformatter.string(from: d!)
            
            
        }
        else{
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let showDate = inputFormatter.date(from: t)
            if(showDate != nil)
            {
                resultString = outputFormatter.string(from: showDate!)
                outdate=dateformatter.string(from: showDate!)
                
            }
            
            print(resultString)
            
            
        }
        
        
        let outtime: String = ""
        if (FLAG=="D" || FLAG=="DT") {
            
            //Current Date Message
            if (outdate == currentdate && outdate != "") {
                datetimevalue = "Today"
                
            } else {
                let cal=NSCalendar.current
                let oneDayAgo = cal.date(byAdding: .day, value: -1, to: Date())
                let d1 = dateformatter.string(from: oneDayAgo!)
                
                if (outdate == d1) {
                    datetimevalue = "Yesterday";
                    
                } else {
                    var twodaysAgo = cal.date(byAdding: .day, value: -2, to: Date())
                    var daysago = dateformatter.string(from: twodaysAgo!)
                    
                    
                    
                    
                    
                    var count = -3
                    for i in 0...5
                    {
                        if (outdate == daysago) {
                            let day:Int = cal.component(.weekday, from: twodaysAgo!)
                            datetimevalue = getDayOfWeek(day: day)
                            break
                        }
                        else{
                            if (i == 4) {
                                if(d != nil){
                                    datetimevalue = dateformatter1.string(from: d!)
                                }
                                else{
                                    
                                    datetimevalue = t
                                }
                                
                                
                            } else
                            {
                                twodaysAgo = cal.date(byAdding: .day, value: count, to: Date())
                                daysago = dateformatter.string(from: twodaysAgo!)
                                count  = count-1
                            }
                        }
                        
                    }
                }
                
                if (FLAG == "DT")
                {
                    datetimevalue = datetimevalue + " " + outtime
                }
                else {
                    if(FLAG == "T"){
                        datetimevalue = outtime
                    }
                    
                }
                
            }
        }
        return datetimevalue;
    }
    

        
    
    
}
