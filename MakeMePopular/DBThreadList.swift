//
//  GetThreadList.swift
//  MakeMePopular
//
//  Created by sachin shinde on 10/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import CoreData
import ObjectMapper
class DBThreadList: NSObject {
    
    // Fallback on earlier versions
    
    
    var context:NSManagedObjectContext!
    func insertthreadlist(threadlist:ThreadlistModel)
    {
        let appdel:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        
        if #available(iOS 10.0, *) {
            context = appdel.persistentContainer.viewContext
        } else {
            
            
            
            
            // Fallback on earlier versions
        }
        
        let newname=NSEntityDescription.entity(forEntityName: "Threadlist", in: self.context)
        print(newname!)
        let newuser=Threadlist(entity: newname!,insertInto: self.context)
        
        
        newuser.setValue(threadlist.threadId, forKey:"threadId")
        newuser.setValue(threadlist.threadName, forKey: "threadName")
        newuser.setValue(threadlist.thumbnailUrl, forKey: "thumbnailUrl")
        newuser.setValue(threadlist.lastSenderName, forKey:"lastSenderName")
        newuser.setValue(threadlist.badgeCount!, forKey: "badgeCount")
        newuser.setValue(threadlist.timeStamp , forKey: "timeStamp")
        newuser.setValue(threadlist.lastSenderById, forKey:"lastSenderById")
        newuser.setValue(threadlist.lastMessageId, forKey: "lastMessageId")
        newuser.setValue(threadlist.lastMessageText, forKey: "lastMessageText")
        newuser.setValue(threadlist.initiateId!, forKey: "initiateId")
        newuser.setValue(threadlist.initiateName!, forKey: "initiateName")
        
        newuser.setValue(threadlist.threadCustomName!, forKey: "threadCustomName")
        newuser.setValue(threadlist.participantList!, forKey: "participantList")
        print(threadlist.participantList!)
        
        print(threadlist.badgeCount!)
        
        do {
            try self.context.save()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        print(newuser)
        
        print("save")
    }
    
    func getThread(threadId:String) -> Bool {
        
        var isPresent:Bool = false
        //create a fetch request, telling it about the entity
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Threadlist")
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
    
    
    
    func getreceiverId(receiverId:String) -> Bool {
        
        var isPresent:Bool = false
        //create a fetch request, telling it about the entity
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Threadlist")
        let predicate = NSPredicate(format: "participantList == %@", receiverId)
        fetchRequest.predicate = predicate
        
        
        do {
            //go get the results
            if #available(iOS 10.0, *) {
                let searchResults = try getContext().fetch(fetchRequest)
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    
                    var receiver:String = ""
                    if(trans.value(forKey: "participantList") != nil){
                        receiver = trans.value(forKey: "participantList") as! String
                        isPresent = true
                        print(receiver)
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

    func updatethreadlist(threadlist:ThreadlistModel)
    {
        let appdel:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 10.0, *) {
            context = appdel.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
        }
        
        
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Threadlist")
        
        let datesortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [datesortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        let predicate = NSPredicate(format: "threadId == %@", threadlist.threadId!)
        request.predicate = predicate
        print(threadlist.threadId!)
        do {
            //go get the results
            if #available(iOS 10.0, *) {
                let searchResults = try getContext().fetch(request)
                print ("num of results = \(searchResults.count)")
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    trans.setValue(threadlist.lastSenderById, forKey: "lastSenderById")
                    trans.setValue(threadlist.thumbnailUrl, forKey: "thumbnailUrl")
                    trans.setValue(threadlist.lastSenderName, forKey: "lastSenderName")
                    trans.setValue(threadlist.timeStamp, forKey: "timeStamp")
                    trans.setValue(threadlist.lastMessageText, forKey: "lastMessageText")
                    trans.setValue(threadlist.threadCustomName, forKey: "threadCustomName")
                    trans.setValue(threadlist.badgeCount!, forKey: "badgeCount")
                    print(threadlist.badgeCount!)
                    //save the object
                    do {
                        try context.save()
                        print("saved!")
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    } catch {
                        
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
    
    
    func updatebadgecountthread(threadlist:String)
    {
        let appdel:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 10.0, *) {
            context = appdel.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
        }
        
        
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Threadlist")
        
        
        let predicate = NSPredicate(format: "threadId == %@", threadlist)
        request.predicate = predicate
        print(threadlist)
        let b="0"
        do {
            //go get the results
            if #available(iOS 10.0, *) {
                let searchResults = try getContext().fetch(request)
                print ("num of results = \(searchResults.count)")
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    //  threadlist="0"
                    trans.setValue("0", forKey: "badgeCount")
                    print(threadlist)
                    print(b)
                    //save the object
                    do {
                        try context.save()
                        print("saved!")
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    } catch {
                        
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
    func updatebadgecount(threadlist:String)
    {
        let appdel:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 10.0, *) {
            context = appdel.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
        }
        
        
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Threadlist")
        
               
        let predicate = NSPredicate(format: "badgeCount == %@", threadlist)
        request.predicate = predicate
        print(threadlist)
      let b="0"
        do {
            //go get the results
            if #available(iOS 10.0, *) {
                let searchResults = try getContext().fetch(request)
                print ("num of results = \(searchResults.count)")
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                 //  threadlist="0"
                    trans.setValue(b, forKey: "badgeCount")
                    print(threadlist)
                    print(b)
                    //save the object
                    do {
                        try context.save()
                        print("saved!")
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    } catch {
                        
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
    func getupdateddateofthread() -> String{
        
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Threadlist")
        
        
        var time=""
        var c1:Int!
        if #available(iOS 10.0, *) {
            
            do{
                let searchResults=try self.getContext().fetch(request)
                print ("num of results = \(searchResults.count)")
                c1=searchResults.count-1
                print(c1)
                if(searchResults.count != 0)
                {
                    if((searchResults[0] as AnyObject).value(forKey: "timeStamp") != nil){
                        time=(searchResults[0] as AnyObject).value(forKey: "timeStamp") as! String
                        print("\(time)" )
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
    func retriveallrecords() ->[LastMsgDtls]
    {
        
        var LastMsgList=[LastMsgDtls]()
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Threadlist")
        
        let datesortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [datesortDescriptor]
        request.sortDescriptors = sortDescriptors
        if #available(iOS 10.0, *) {
            do{
                let searchResults = try self.getContext().fetch(request)
                
    
                
                //You need to convert to NSManagedObject to use 'for' loops
                for trans in searchResults as! [NSManagedObject] {
                    //get the Key Value pairs (although there may be a better way to do that...
                    var threadId:String = ""
                  
                    var thumbnailUrl:String=""
                    var lastSenderName:String!
                    var badgeCount:String=""
                    var timeStamp:String=""
                    var lastSenderById:String=""
                  
                    var lastMessageText:String=""
                    var initiateId:String=""
                 
                    var threadCustomName:String=""
                    var participantList:String=""
                    if(trans.value(forKey: "threadId") != nil){
                        threadId=trans.value(forKey: "threadId") as! String
                        
                    }
                    
                    
                    if(trans.value(forKey: "thumbnailUrl") != nil){
                        thumbnailUrl=trans.value(forKey: "thumbnailUrl") as! String
                       
                    }
                    if(trans.value(forKey: "lastSenderName") != nil){
                        lastSenderName=trans.value(forKey: "lastSenderName") as! String
                      
                    }
                    if(trans.value(forKey: "badgeCount") != nil){
                        badgeCount=trans.value(forKey: "badgeCount") as! String
                      
                    }
                    if(trans.value(forKey: "timeStamp") != nil){
                        timeStamp=trans.value(forKey: "timeStamp") as! String
                     
                    }
                    if(trans.value(forKey: "lastSenderById") != nil){
                        lastSenderById=trans.value(forKey: "lastSenderById") as! String
                       
                    }
                    
                    
                    
                    if(trans.value(forKey: "lastMessageText") != nil){
                        lastMessageText=trans.value(forKey: "lastMessageText") as! String
                        
                    }
                    
                    if(trans.value(forKey: "initiateId") != nil){
                        initiateId=trans.value(forKey:  "initiateId") as! String
                      
                    }
                   
                    if(trans.value(forKey: "threadCustomName") != nil){
                        threadCustomName=trans.value(forKey: "threadCustomName") as! String
                        
                    }
                    if(trans.value(forKey: "participantList") != nil){
                        participantList=trans.value(forKey: "participantList") as! String
                        
                    }
                   
                    let thread0=LastMsgDtls(LastMsgSender: lastSenderName, Lastmsgtext: lastMessageText, LastMsgTime:  timeStamp, LastmsgSenderimage: thumbnailUrl, ThreadName: threadCustomName,ThreadId: threadId,reciverId:participantList,InitiateId:initiateId,UnreadCount:badgeCount,LastSenderId:lastSenderById)
                    
                    
                                      LastMsgList.append(thread0)
                }
                
                
            }
            catch{}
        }
        else {
            // Fallback on earlier versions
        }
        
        
        return LastMsgList
        
    }
    
    func deleteallvalues(){
        // Create Fetch Request
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Threadlist")
        
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
    
    
    
    @available(iOS 10.0, *)
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override init(){
        
    }
    
}
