//
//  MessageList.swift
//  MakeMePopular
//
//  Created by sachin shinde on 10/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreData

@objc
class DBMessageList: NSObject {
    var context:NSManagedObjectContext!
    func insertMessagelist(messagelist:MessageModel)
    {
        
        let appdel:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if #available(iOS 10.0, *) {
            context = appdel.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
        }
        
        let newname=NSEntityDescription.entity(forEntityName: "MessageList", in: self.context)
        print(newname!)
        let newuser=MessageList(entity: newname!, insertInto: context)
        
        
//       var isr=(messagelist.isRead as NSString).boolValue
//       var isdev=(messagelist.isDeliver as NSString).boolValue
//        var iss=(messagelist.isSend as NSString).boolValue
//        
        
        newuser.setValue(messagelist.messageId, forKey:"messageId")
        newuser.setValue(messagelist.senderId, forKey: "senderId")
        newuser.setValue(messagelist.timeStamp, forKey: "timeStamp")
        newuser.setValue(messagelist.message, forKey:"message")
        newuser.setValue(messagelist.threadId, forKey: "threadId")
        newuser.setValue(messagelist.receiverId , forKey: "receiverId")
        newuser.setValue(messagelist.senderName!, forKey:"senderName")
        newuser.setValue(messagelist.senderThumbnail, forKey: "senderThumbnail")
        newuser.setValue(true, forKey: "isSend")
        newuser.setValue(messagelist.isRead, forKey: "isRead")
        newuser.setValue(messagelist.isDeliver, forKey: "isDeliver")

        print(messagelist.isDeliver!)
        
         print(messagelist.isRead!)
        
        do {
            try self.context.save()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        print(newuser)
        
        print("save")
    }
    func insertMessagelistNotice(messageId:String,senderId:String,timeStamp:String,message:String,threadId:String,receiverId:String,senderName:String,senderThumbnail:String,isread:Bool,isdelever:Bool,issend:Bool)
    {
        
        let appdel:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if #available(iOS 10.0, *) {
            context = appdel.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
        }
        
        let newname=NSEntityDescription.entity(forEntityName: "MessageList", in: self.context)
        print(newname!)
        let newuser=MessageList(entity: newname!, insertInto: context)
        
        
        newuser.setValue(messageId, forKey:"messageId")
        newuser.setValue(senderId, forKey: "senderId")
        newuser.setValue(timeStamp, forKey: "timeStamp")
        newuser.setValue(message, forKey:"message")
        newuser.setValue(threadId, forKey: "threadId")
        newuser.setValue(receiverId , forKey: "receiverId")
        newuser.setValue(senderName, forKey:"senderName")
        newuser.setValue(senderThumbnail, forKey: "senderThumbnail")
        newuser.setValue(true, forKey: "isSend")
        newuser.setValue(isread, forKey: "isRead")
        newuser.setValue(isdelever, forKey: "isDeliver")

        print("isread :\(isread) isdelever:\(isdelever)")
        print(senderName)
        
        
        do {
            try self.context.save()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        print(newuser)
        
        print("save")
    }
    @available(iOS 10.0, *)
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    func retriveonlydates(threadid:String)->[String]
    {
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "MessageList")
        
        
        let predicate = NSPredicate(format: "threadId == %@", threadid)
        request.predicate = predicate
        
        let datesortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [datesortDescriptor]
        request.sortDescriptors = sortDescriptors

        
        
        
        var LastMsg=[String]()
        if #available(iOS 10.0, *) {
            
            do{
                let searchResults=try self.getContext().fetch(request)
                print ("num of results = \(searchResults.count)")
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    
                    
                    var timeStamp:String=""
                    var t:String=""
                    
                    if(trans.value(forKey: "timeStamp") != nil){
                        timeStamp=trans.value(forKey: "timeStamp") as! String
                        t=timeStamp.components(separatedBy: "T")[0]
                    }
                    
                   
                  //  let msgget=Message(MsgTime: timeStamp)
                    
                    LastMsg.append(t)
                    
                }
                
            }
            catch
            {
                
            }
        } else {
            // Fallback on earlier versions
        }
        return LastMsg
        


        
    }
    
    func lastupdatetime(thid:String,receiverid:String)->String
    {
        
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "MessageList")
        
        let predicate = NSPredicate(format: "threadId == %@" , thid)
       
     let p1 =  NSPredicate(format: "receiverId == %@" , receiverid)
        request.predicate = predicate
        request.predicate=p1
        var time=""
        var c1:Int!
        
        let datesortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [datesortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        if #available(iOS 10.0, *) {
            
            do{
                let searchResults=try self.getContext().fetch(request)
                print ("num of results = \(searchResults.count)")
                c1=searchResults.count-1
                print(c1)
//                var p=(searchResults[0] as AnyObject).value(forKey: "timeStamp") as! String
//                print(p)
                if(searchResults.count != 0)
                {
                    if((searchResults[0] as AnyObject).value(forKey: "timeStamp") != nil){
                        time=(searchResults[0] as AnyObject).value(forKey: "timeStamp") as! String
                        print(time)
                    }
                    
                }
                else{
                    time=""
                }
            }
                
                
            catch
            {
                print("no result")
            }
        }
        return time
        
    }
    func getThread(threadId:String) -> Bool {
        
        var isPresent:Bool = false
        //create a fetch request, telling it about the entity
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MessageList")
        let predicate = NSPredicate(format: "threadId == %@", threadId)
        fetchRequest.predicate = predicate
        
        
        do {
            //go get the results
            if #available(iOS 10.0, *) {
                let searchResults = try getContext().fetch(fetchRequest)
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    
                    var threadid:String = ""
                    if(trans.value(forKey: "threadId") != nil){
                        threadid = trans.value(forKey: "threadId") as! String
                        isPresent = true
                        print(threadid)
                    }
                    
                }
                print ("num of results = \(searchResults.count)")
                
            } else {
                // Fallback on earlier versions
            }
            
            //I like to check the size of the returned results!
            
            //You need to convert to NSManagedObject to use 'for' loops
        } catch {
            print("Error with request: \(error)")
        }
        
        return isPresent
    }
    
    
    func updatemessagemodel(messagelist:MessageModel){
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MessageList")
        let predicate = NSPredicate(format: "messageId == %@", messagelist.messageId!)
        //let predicate1 = NSPredicate(format: "threadId == %@", messagelist.threadId!)
        fetchRequest.predicate = predicate
        //fetchRequest.predicate = predicate1
        
        
        
//        print("isread:\(isread) isdelever:\(isdelever) issend:\(issend)")
//        
//        
//        let isr=(isread as? NSString)?.boolValue
//        let  isdev=(isdelever as? NSString)?.boolValue
        let iss:Bool=true
        do {
            //go get the results
            if #available(iOS 10.0, *) {
                let searchResults = try getContext().fetch(fetchRequest)
                print ("num of results = \(searchResults.count)")
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    
//                    print(isr!)
//                    print(isdev!)
//                    
                    
//                    let m=self.BoolToString(b: msg?.isRead)
//                    let m2=self.BoolToString(b: msg?.isDeliver)
//                    let m3=self.BoolToString(b: msg?.isSend)
//
                    if(messagelist.isRead==nil)
                    {
                        messagelist.isRead=false
                    }
                    if(messagelist.isDeliver==nil)
                    {
                        messagelist.isDeliver=false
                    }
                    
                    trans.setValue(messagelist.messageId, forKey:"messageId")
                   trans.setValue(messagelist.senderId, forKey: "senderId")
                    trans.setValue(messagelist.timeStamp, forKey: "timeStamp")
                    trans.setValue(messagelist.message, forKey:"message")
                    trans.setValue(messagelist.threadId, forKey: "threadId")
                    trans.setValue(messagelist.receiverId , forKey: "receiverId")
                    trans.setValue(messagelist.senderName!, forKey:"senderName")
                   trans.setValue(messagelist.senderThumbnail, forKey: "senderThumbnail")
                  
                    trans.setValue(messagelist.isRead, forKey: "isRead")
                    trans.setValue(true, forKey: "isDeliver")
                    trans.setValue(true, forKey: "isSend")
                    
                    
                    //save the object
                    do {
                        
                        
                        try self.getContext().save()
                        
                        
                        
                    } catch {
                        
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    
                    
                }
                
            } else {
                // Fallback on earlier versions
            }
            
            //I like to check the size of the returned results!
        }
        catch {
            // Do something in response to error condition
        }
        
        
        
        
        
        
        
    }
    
    func BoolToString(b: Bool?)->String { return b?.description ?? "<None>"}
    func updatemessage(messageid:String,threadid:String,isread:String,isdelever:String,issend:String){
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MessageList")
        let predicate = NSPredicate(format: "messageId == %@", messageid)
      //  let predicate1 = NSPredicate(format: "threadId == %@", threadid)
        fetchRequest.predicate = predicate
      //fetchRequest.predicate = predicate1
        
        print(messageid)
       
       // print(threadid)
        
        
        
       print("isread:\(isread) isdelever:\(isdelever) issend:\(issend)")

        
        let isr=(isread as? NSString)?.boolValue
      let  isdev=(isdelever as? NSString)?.boolValue
        let iss:Bool=true
        do {
            //go get the results
            if #available(iOS 10.0, *) {
                let searchResults = try getContext().fetch(fetchRequest)
                print ("num of results = \(searchResults.count)")
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    
                    print(isr!)
                    print(isdev!)
                   
                    trans.setValue(isr, forKey: "isRead")
                    trans.setValue(isdev, forKey: "isDeliver")
                    trans.setValue(iss, forKey: "isSend")
                    
                    
                    //save the object
                   do {
                        try self.getContext().save()
                    } catch {
                        
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }

                    
                }
                
            } else {
                // Fallback on earlier versions
            }
            
            //I like to check the size of the returned results!
        }
        catch {
            // Do something in response to error condition
        }
        

        
        
        
        

    }

    func getmessage(messageid:String) -> Bool {
        
        var isPresent:Bool = false
        //create a fetch request, telling it about the entity
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MessageList")
        let predicate = NSPredicate(format: "messageId == %@", messageid)
        fetchRequest.predicate = predicate
        
        
        do {
            //go get the results
            if #available(iOS 10.0, *) {
                let searchResults = try getContext().fetch(fetchRequest)
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    
                    var messageId:String = ""
                    if(trans.value(forKey: "messageId") != nil){
                        messageId = trans.value(forKey: "messageId") as! String
                        isPresent = true
                        print(messageId)
                    }
                    
                }
                print ("num of results = \(searchResults.count)")
                
            } else {
                // Fallback on earlier versions
            }
            
            //I like to check the size of the returned results!
            
            //You need to convert to NSManagedObject to use 'for' loops
        } catch {
            print("Error with request: \(error)")
        }
        
        return isPresent
    }
    func updatealldelever(threadid:String){
        
        
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "MessageList")
        
        
        let predicate = NSPredicate(format: "threadId == %@", threadid)
        request.predicate = predicate
        
        
        if #available(iOS 10.0, *){
        
        
        do{
            let searchResults=try self.getContext().fetch(request)
            print ("num of results = \(searchResults.count)")
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as! [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                
                
                var isdeliver:Bool=true
        
               trans.setValue(isdeliver, forKey: "isDeliver")
                trans.setValue(true, forKey: "isRead")
                do {
                    if #available(iOS 10.0, *) {
                        try self.getContext().execute(request)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                } catch {
                    // Error Handling
                }

                
            }
            
        }
        catch
        {
            
        }
        }else{}
    

    
    }
    func retriveallmessage(threadid:String) ->[Message]
    {
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "MessageList")
        
        
        let predicate = NSPredicate(format: "threadId == %@", threadid)
        request.predicate = predicate
       

        
      
        
        var LastMsg=[Message]()
        var Msggroup=[[Message]]()
        if #available(iOS 10.0, *) {
            
            do{
                let searchResults=try self.getContext().fetch(request)
                print ("num of results = \(searchResults.count)")
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                   
                  
                    var timeStamp:String=""
                    var message:String!
                    var issend:Bool=true
                    var isdeliver:Bool=true
                    var isread:Bool=true
                    var SenderName:String=""
                    var senderThumbnail:String=""
                  
                    if(trans.value(forKey: "message") != nil){
                        message=trans.value(forKey: "message") as! String
                     
                    }
                    
                    if(trans.value(forKey: "isRead") != nil){
                        isread=trans.value(forKey: "isRead") as! Bool
                        
                    }
                    if(trans.value(forKey: "isSend") != nil){
                        issend=trans.value(forKey: "isSend") as! Bool
                        
                    }
                    if(trans.value(forKey: "isDeliver") != nil){
                        isdeliver=trans.value(forKey: "isDeliver") as! Bool
                        
                    }
                    
                    if(trans.value(forKey: "timeStamp") != nil){
                        timeStamp=trans.value(forKey: "timeStamp") as! String
                       
                    }
                    
                    if(trans.value(forKey: "senderName") != nil){
                        SenderName=trans.value(forKey: "senderName") as! String
                        UserDefaults.standard.set(SenderName, forKey: "SenderName")
                      
                    }
                    if(trans.value(forKey: "senderThumbnail") != nil){
                        senderThumbnail=trans.value(forKey: "senderThumbnail") as! String
                       
                        UserDefaults.standard.set(senderThumbnail, forKey: "Senderpic")
                    }
                    let msgget=Message(MsgSender: SenderName, msgtext: message, MsgTime:timeStamp, msgSenderimage: senderThumbnail, isRead: isread, isdelever: isdeliver,isSend:true)
                    
                    LastMsg.append(msgget)
                  
                }
                
            }
            catch
            {
               
            }
        } else {
            // Fallback on earlier versions
        }
        return LastMsg
        
    }
    
    
    
    
    func retriveallmessage() ->[Message]
    {
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "MessageList")
        
        
   
        
        
        
        var LastMsg=[Message]()
        if #available(iOS 10.0, *) {
            
            do{
                let searchResults=try self.getContext().fetch(request)
                print ("num of results = \(searchResults.count)")
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    var messageid:String = ""
                    var senderId:String=""
                    var timeStamp:String=""
                    var message:String!
                    var threadId:String=""
                    var receiverId:String=""
                    var SenderName:String=""
                    var senderThumbnail:String=""
                    var isread:Bool=false
                    var isdelever:Bool=false
                    var issend:Bool=true
                    if(trans.value(forKey: "messageId") != nil){
                        messageid=trans.value(forKey: "messageId") as! String
                        print(messageid)
                    }
                    if(trans.value(forKey: "isRead") != nil){
                        isread=trans.value(forKey: "isRead") as! Bool
                        print(isread)
                    }
                    if(trans.value(forKey: "isDeliver") != nil){
                        isdelever=trans.value(forKey: "isDeliver") as! Bool
                        print(isdelever)
                    }
                    if(trans.value(forKey: "isSend") != nil){
                        issend=trans.value(forKey: "isSend") as! Bool
                        print(issend)
                    }
                    
                    if(trans.value(forKey: "message") != nil){
                        message=trans.value(forKey: "message") as! String
                        print( message)
                    }
                    
                    if(trans.value(forKey: "senderId") != nil){
                        senderId=trans.value(forKey: "senderId") as! String
                        print(senderId)
                    }
                    if(trans.value(forKey: "threadId") != nil){
                        threadId=trans.value(forKey: "threadId") as! String
                        print(threadId)
                    }
                    if(trans.value(forKey: "timeStamp") != nil){
                        timeStamp=trans.value(forKey: "timeStamp") as! String
                        print(timeStamp)
                    }
                    if(trans.value(forKey: "receiverId") != nil){
                        receiverId=trans.value(forKey: "receiverId") as! String
                        print(receiverId)
                    }
                    if(trans.value(forKey: "senderName") != nil){
                        SenderName=trans.value(forKey: "senderName") as! String
                        UserDefaults.standard.set(SenderName, forKey: "SenderName")
                        print(SenderName)
                    }
                    if(trans.value(forKey: "senderThumbnail") != nil){
                        senderThumbnail=trans.value(forKey: "senderThumbnail") as! String
                        print(senderThumbnail)
                        UserDefaults.standard.set(senderThumbnail, forKey: "Senderpic")
                    }
                    let msgget=Message(MsgSender: SenderName, msgtext: message, MsgTime:timeStamp, msgSenderimage: senderThumbnail, isRead: isread, isdelever: isdelever, isSend: true)//Message(MsgSender: SenderName, msgtext: message, MsgTime:timeStamp, msgSenderimage: senderThumbnail)
                    LastMsg.append(msgget)
                    
                }
                
            }
            catch
            {
                print("no result")
            }
        } else {
            // Fallback on earlier versions
        }
        return LastMsg
        
    }
    func deleteallvalues(){
        // Create Fetch Request
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MessageList")
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            if #available(iOS 10.0, *) {
                try self.getContext().execute(batchDeleteRequest)
            } else {
                // Fallback on earlier versions
            }
            
        } catch {
            // Error Handling
        }
    }

    override init(){
    }
    
    
}
