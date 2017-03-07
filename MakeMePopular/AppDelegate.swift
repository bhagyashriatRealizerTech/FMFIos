//
//  AppDelegate.swift
//  MakeMePopular
//
//  Created by sachin shinde on 10/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import CoreData
import FirebaseInstanceID
import FirebaseMessaging
import Firebase
import GoogleMaps
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate, GMSMapViewDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var city:String = ""


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyBRCaTuWAP6PwYSS2DEmEpxTFaWdOBiVqM")
        
    
        if #available(iOS 8.0, *){
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        else{
            let types:UIRemoteNotificationType = [.alert, .badge, .sound]
            application.registerForRemoteNotifications(matching: types)
        }
        
        FIRApp.configure()
        
        NSSetUncaughtExceptionHandler { exception in
            print(exception)
            print(exception.callStackSymbols)
            let utils = Utils()
            utils.sendMail(text: exception.callStackSymbols.joined(separator: "\n"))
        }
        
        
        return true
    }
    
  
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
       
        if(application.applicationState == UIApplicationState.active) {
            
                      var type:String = ""
            var message:String = ""
            var senderId:String = ""
            var notifId:String = ""
            var notifThumbnailurl:String = ""
            var userName:String = ""
            
            if let notitype = userInfo["Type"] as? String {
                
                type = notitype
            }
            
            if let notiid = userInfo["NotificationId"] as? String {
                
                notifId = notiid
            }
            
            if(type == "FriendRequest"){
                
                if let name = userInfo["RequsetByName"] as? String {
                    userName = name
                    message = name + " sent you Friend Request"
                }
                
                if let senderid = userInfo["RequsetByUserId"] as? String {
                    
                    senderId = senderid
                }
                if let gender = userInfo["Gender"] as? String {
                    
                    message = message + "\n" + gender
                }
                if let age = userInfo["Age"] as? String {
                    
                    message = message + ", " + age
                }
                if let adrs = userInfo["Address"] as? String {
                    
                    message = message + ", " + adrs
                }

                if let thumbnail = userInfo["ThumbnailUrl"] as? String {
                    
                    notifThumbnailurl = thumbnail
                }
                
                
                
            }
                else if(type == "SendMessage")
            {
                
                var message:String!
                var sendby:String!
                var thid:String!
                var time:String!
                var participateid:String!
                var image:String!
                var msgid:Any!
                var initiateid:Any!
                              if let messageID1 = userInfo["messageId"] {
                    print("Message ID: \(messageID1)")
                    msgid = messageID1
                    UserDefaults.standard.set(msgid, forKey: "MessageID")
                    
                }
             
                if let initiateId1 = userInfo["initiateId"] {
                
                    initiateid=initiateId1
                    UserDefaults.standard.set(initiateid, forKey: "InitiateID")
                   
                }
                
                if let img=userInfo["senderThumbnailUrl"] as? String{
                    image=img
                  
                    if(img=="")
                    {
                        UserDefaults.standard.set("", forKey: "SenderPic")
                    }
                    else{
                        UserDefaults.standard.set(image, forKey: "SenderPic")
                    }
                    
                }
                
                if let threadid=userInfo["threadId"] as? String{
                    thid=threadid
                    UserDefaults.standard.set(thid, forKey: "THID")
                }
                if let partiid=userInfo["participantId"] as? String{
                    participateid=partiid
                    UserDefaults.standard.set(participateid, forKey: "ParticipateID")
                    
                }
                
                if let timestam=userInfo["timeStamp"] as? String{
                    time=timestam
                    UserDefaults.standard.set(time, forKey: "Time")
                    
                }
                if let aps = userInfo["aps"] as? NSDictionary {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let alertMessage = alert["body"] as? String {
                            message = alertMessage
                            UserDefaults.standard.set(message, forKey: "MSG")
                        }
                        if let title = alert["title"] as? String {
                            sendby = title
                            UserDefaults.standard.set(sendby, forKey: "SendBy")
                            
                        }
                        
                    }
                }
            
                
                              
                
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMessage"), object: nil)
                
                
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadThread"), object: nil)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadDash"), object: nil)


            }
          
            else if(type == "Emergency"){
                
                if let name = userInfo["TroublerName"] as? String {
                    userName = name
                    message = name
                }
                if let msg = userInfo["Message"] as? String {
                    
                    message = message + ": " + msg
                }
                
                if let senderid = userInfo["TroublerUserId"] as? String {
                    
                    senderId = senderid
                }
                if let thumbnail = userInfo["ThumbnailUrl"] as? String {
                    
                    notifThumbnailurl = thumbnail
                }
                
            }
         
            else if(type == "EmergencyRecipt"){
                
                if let name = userInfo["HelperUserName"] as? String {
                    
                    message = name
                    if let isReach = userInfo["isReaching"] as? String {
                        if(isReach == "true"){
                            message = message + " acknowledged your emergency message"
                        }
                        else{
                            message = message + " ignored your emergency message"
                        }
                    }
                }
                
                if let senderid = userInfo["HelperUserId"] as? String {
                    
                    senderId = senderid
                }
                
                
            }
            else if(type == "TrackingStarted"){
                
                
                 self.getCurrentLocation()
                
                if let name = userInfo["TrackingByUserName"] as? String {
                    
                    message = name + " started Tracking you"
                }
                
                if let senderid = userInfo["TrackingByUserId"] as? String {
                    
                    senderId = senderid
                }
                
                
            }
            else if(type == "FriendRequestAccepted"){
                
                if let name = userInfo["AcceptByName"] as? String {
                    
                    message = name + " has accepted your Friend Request"
                }
                
                if let senderid = userInfo["AcceptByUserId"] as? String {
                    
                    senderId = senderid
                }
                
            }
           if(type=="ReadReceipt"){
            print(userInfo)
                var notid:String=""
                var msgid:String=""
                var isRead:String="false"
                var isdeliver:String="false"
            var thid:String=""
                if let NotificationId=userInfo["NotificationId"] as? String{
                    notid=NotificationId
                    UserDefaults.standard.set(notid, forKey: "NoticeId")
                                }
            
            
            
            if let MessageId=userInfo["MessageId"] as? String{
            
            msgid=MessageId
            UserDefaults.standard.set(msgid, forKey: "MsgId")
            
            }
            if let IsRead=userInfo["IsRead"] as? String{
                
                isRead=IsRead
                
               UserDefaults.standard.set(isRead, forKey: "IsRead")
                print(isRead)
            }
            
            if let Isdeliver=userInfo["Isdeliver"] as? String{
                
                isdeliver=Isdeliver
                UserDefaults.standard.set(isdeliver, forKey: "IsDeliver")
                 print(isdeliver)
                
            }
            if let ThreadId=userInfo["ThreadId"] as? String{
                
                thid=ThreadId
                UserDefaults.standard.set(thid, forKey: "ThreadId")
                
            }
            
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceiveNotification"), object: nil)
            }
            if(type == "EmergencyRecipt" || type == "Emergency" || type == "FriendRequest" || type == "FriendRequestAccepted"){
                let pref = UserDefaults.standard
                pref.setValue(message, forKey: "MessageText")
                pref.setValue(senderId, forKey: "SenderID")
                pref.set(type, forKey: "Type")
                pref.set(notifId, forKey: "NotifId")
                pref.set(notifThumbnailurl, forKey: "NotiURL")
                pref.set(userName, forKey: "NotiUserName")
                pref.synchronize()
                
                
                let rootVC = self.window!.rootViewController
                let mainvc = MainVC()
                
                rootVC?.navigationController?.pushViewController(mainvc, animated: true)
                
                
                print(userInfo)
                
                
                
                
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "recievednotif"), object: nil)
               
            }
            
           
            
        }
    else if(application.applicationState == UIApplicationState.background){
            
            //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
            
            // Print full message.
            
           var type:String = ""
           
            if let notitype = userInfo["Type"] as? String {
                
                type = notitype
            }
             if(type == "TrackingStarted"){
                
                self.getCurrentLocation()
            }
            
        if(type == "SendMessage")
             {
                var message:String!
                var sendby:String!
                var thid:String!
                var time:String!
                var participateid:String!
                var image:String!
                var msgid:Any!
                var initiateid:Any!
              
                if let messageID1 = userInfo["messageId"] {
                    print("Message ID: \(messageID1)")
                    msgid = messageID1
                    UserDefaults.standard.set(msgid, forKey: "MessageID")
                  
                }
                
                if let initiateId1 = userInfo["initiateId"] {
                    print("Initiate ID: \(initiateId1)")
                    initiateid=initiateId1
                    UserDefaults.standard.set(initiateid, forKey: "InitiateID")
                   
                }
                
                if let img=userInfo["senderThumbanilUrl"] as? String{
                    image=img
                    UserDefaults.standard.set(image, forKey: "SenderPic")
                }
                
                if let threadid=userInfo["threadId"] as? String{
                    thid=threadid
                    UserDefaults.standard.set(thid, forKey: "THID")
                }
                if let partiid=userInfo["participantId"] as? String{
                    participateid=partiid
                    UserDefaults.standard.set(participateid, forKey: "ParticipateID")
                    
                }
                
                if let timestam=userInfo["timeStamp"] as? String{
                    time=timestam
                    UserDefaults.standard.set(time, forKey: "Time")
                    
                }
                if let aps = userInfo["aps"] as? NSDictionary {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let alertMessage = alert["body"] as? String {
                            message = alertMessage
                            UserDefaults.standard.set(message, forKey: "MSG")
                        }
                        if let title = alert["title"] as? String {
                            sendby = title
                            UserDefaults.standard.set(sendby, forKey: "SendBy")
                            
                        }
                        
                    }
                }
             
                
                
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMessage"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadThread"), object: nil)
                
               
                
            }
            
            
             if(type=="ReadReceipt")
            {
                print(userInfo)
                var notid:String=""
                var msgid:String=""
                var isRead:String="false"
                var isdeliver:String="false"
                var thid:String=""
                if let NotificationId=userInfo["NotificationId"] as? String{
                    notid=NotificationId
                    UserDefaults.standard.set(notid, forKey: "NoticeId")
                }
                
                
                
                if let MessageId=userInfo["MessageId"] as? String{
                    
                    msgid=MessageId
                    UserDefaults.standard.set(msgid, forKey: "MsgId")
                    
                }
                if let IsRead=userInfo["IsRead"] as? String{
                    
                    isRead=IsRead
                    
                    UserDefaults.standard.set(isRead, forKey: "IsRead")
                    print(isRead)
                }
                
                if let Isdeliver=userInfo["Isdeliver"] as? String{
                    
                    isdeliver=Isdeliver
                    UserDefaults.standard.set(isdeliver, forKey: "IsDeliver")
                    print(isdeliver)
                    
                }
                if let ThreadId=userInfo["ThreadId"] as? String{
                    
                    thid=ThreadId
                    UserDefaults.standard.set(thid, forKey: "ThreadId")
                    
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceiveNotification"), object: nil)
            }
        
        }
        else if(application.applicationState == UIApplicationState.inactive){
            
            //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
            var type:String = ""
            var message:String = ""
            var senderId:String = ""
            var notifId:String = ""
            var notifThumbnailurl:String = ""
            var userName:String = ""

            
            if let notitype = userInfo["Type"] as? String {
                
                type = notitype
            }
            if let notiid = userInfo["NotificationId"] as? String {
                
                notifId = notiid
            }
            if(type == "FriendRequest"){
                
                if let name = userInfo["RequsetByName"] as? String {
                    
                    userName = name
                    message = name + " sent you Friend Request"
                }
                
                if let senderid = userInfo["RequsetByUserId"] as? String {
                    
                    senderId = senderid
                }
                if let thumbnail = userInfo["ThumbnailUrl"] as? String {
                    
                    notifThumbnailurl = thumbnail
                }
                if let gender = userInfo["Gender"] as? String {
                    
                    message = message + "\n" + gender
                }
                if let age = userInfo["Age"] as? String {
                    
                    message = message + ", " + age
                }
                if let adrs = userInfo["Address"] as? String {
                    
                    message = message + ", " + adrs
                }
                
                
                
            }
            else if(type == "Emergency"){
                
                if let name = userInfo["TroublerName"] as? String {
                    userName = name
                    message = name
                }
                if let msg = userInfo["Message"] as? String {
                    
                    message = message + ": " + msg
                }
                
                if let senderid = userInfo["TroublerUserId"] as? String {
                    
                    senderId = senderid
                }
                if let thumbnail = userInfo["ThumbnailUrl"] as? String {
                    
                    notifThumbnailurl = thumbnail
                }

                
            }
            else if(type == "FriendRequestAccepted"){
                
                if let name = userInfo["AcceptByName"] as? String {
                    
                    message = name + " has accepted your Friend Request"
                }
                
                if let senderid = userInfo["AcceptByUserId"] as? String {
                    
                    senderId = senderid
                }
                
            }
                
            else if(type == "FriendRequestRejected"){
                
                if let name = userInfo["AcceptByName"] as? String {
                    
                    message = name + " rejected your Friend Request"
                }
                
                if let senderid = userInfo["AcceptByUserId"] as? String {
                    
                    senderId = senderid
                }
                
            }
            
            else if(type == "EmergencyRecipt"){
                
                if let name = userInfo["HelperUserName"] as? String {
                    
                    message = name
                    if let isReach = userInfo["isReaching"] as? String {
                        if(isReach == "true"){
                            message = message + " acknowledged your emergency message"
                        }
                        else{
                            message = message + " ignored your emergency message"
                        }
                    }
                }
                
                if let senderid = userInfo["HelperUserId"] as? String {
                    
                    senderId = senderid
                }

                
            }
            else if(type == "TrackingRequest"){
                
            }
            else if(type == "ApproveTracking"){
                
                
            }
            else if(type == "TrackingStarted"){
                
               
               self.getCurrentLocation()
                
                if let name = userInfo["TrackingByUserName"] as? String {
                    
                    message = name + " started Tracking you"
                }
                
                if let senderid = userInfo["AcceptByUserId"] as? String {
                    
                    senderId = senderid
                }

                
            }
            else if(type == "SendMessage")
            {
                var message:String!
                var sendby:String!
                var thid:String!
                var time:String!
                var participateid:String!
                var image:String!
                var msgid:Any!
                var initiateid:Any!
                var notificationId:Any!
                var gcmid:Any!
                if let messageID1 = userInfo["messageId"] {
                    print("Message ID: \(messageID1)")
                    msgid = messageID1
                    UserDefaults.standard.set(msgid, forKey: "MessageID")
                    print(msgid)
                }
                if let Gcmid = userInfo["gcm.message_id"] {
                    print("gcm.message_id ID: \(Gcmid)")
                    gcmid=Gcmid
                    print(gcmid)
                }
                if let NotificationId = userInfo["NotificationId"] {
                    print("noti ID: \(NotificationId)")
                    notificationId=NotificationId
                    print(notificationId)
                }
                if let initiateId1 = userInfo["initiateId"] {
                    print("Initiate ID: \(initiateId1)")
                    initiateid=initiateId1
                    UserDefaults.standard.set(initiateid, forKey: "InitiateID")
                    print(initiateid )
                }
                
                if let img=userInfo["senderThumbanilUrl"] as? String{
                    image=img
                    UserDefaults.standard.set(image, forKey: "SenderPic")
                }
                
                if let threadid=userInfo["threadId"] as? String{
                    thid=threadid
                    UserDefaults.standard.set(thid, forKey: "THID")
                }
                if let partiid=userInfo["participantId"] as? String{
                    participateid=partiid
                    UserDefaults.standard.set(participateid, forKey: "ParticipateID")
                    
                }
                
                if let timestam=userInfo["timeStamp"] as? String{
                    time=timestam
                    UserDefaults.standard.set(time, forKey: "Time")
                    
                }
                if let aps = userInfo["aps"] as? NSDictionary {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let alertMessage = alert["body"] as? String {
                            message = alertMessage
                            UserDefaults.standard.set(message, forKey: "MSG")
                        }
                        if let title = alert["title"] as? String {
                            sendby = title
                            UserDefaults.standard.set(sendby, forKey: "SendBy")
                            
                        }
                        
                    }
                }
                
                
                let alert0 : AnyObject?=userInfo["aps"] as AnyObject?
                print(alert0!)
                let a:AnyObject=alert0 as AnyObject
                print(a)
                
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMessage"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadThread"), object: nil)
                
               
                
            }
            
            
            let pref = UserDefaults.standard
            pref.setValue(message, forKey: "MessageText")
            pref.setValue(senderId, forKey: "SenderID")
            pref.set(type, forKey: "Type")
            pref.set(notifId, forKey: "NotifId")
            pref.set(notifThumbnailurl, forKey: "NotiURL")
            pref.set(userName, forKey: "NotiUserName")
            pref.synchronize()
            
            
            let rootVC = self.window!.rootViewController
            let mainvc = MainVC()
            
            rootVC?.navigationController?.pushViewController(mainvc, animated: true)
            

              NotificationCenter.default.post(name: NSNotification.Name(rawValue: "recievednotif"), object: nil)
        }
        else{
            if let notitype = userInfo["Type"] as? String {
                
                if(notitype == "TrackingStarted"){
                    self.getCurrentLocation()
                }
            }
        }
        
        
        completionHandler(UIBackgroundFetchResult.newData)

        
    }
    
   

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FIRMessaging.messaging().disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFCM()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MakeMePopular")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()


    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = NSPersistentStoreCoordinator()
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
       
        return managedObjectContext
    }()
    // MARK: - Core Data Saving support

    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
            // Fallback on earlier versions
        }
        
    }
    
    func connectToFCM(){
        
        FIRMessaging.messaging().connect{ (error) in
            if(error != nil){
                print("Unable to connect\(error)")
            }
            else{
                print("Connected to FCM")
            }
            
        }
    }
    
    func getCurrentLocation(){
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.requestLocation()
        }
        
        self.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let location:CLLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            //print(placeMark.addressDictionary)
            
            // City
            if(placeMark != nil){
                var adrs = ""
                if(placeMark.locality != nil){
                    self.city = placeMark.subAdministrativeArea! as String
                }
                
                if(placeMark.thoroughfare != nil){
                    adrs = placeMark.thoroughfare! as String
                    
                }
                if(placeMark.subThoroughfare != nil){
                    adrs = adrs + " " + placeMark.subThoroughfare! as String
                    
                }
                if(placeMark.subLocality != nil){
                    adrs = adrs + " " + placeMark.subLocality! as String
                    print(adrs)
                }
                print(self.city)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let newDate = dateFormatter.string(from: Date())
                
                let pref = UserDefaults.standard
                pref.setValue(self.city, forKey: "UserCity")
                pref.setValue(adrs, forKey: "UserAdrs")
                pref.set(locValue.latitude, forKey: "latitude")
                pref.set(locValue.longitude, forKey: "longitude")
                pref.set(newDate, forKey: "locationBroadccast")
                pref.synchronize()
                
                if(Reachability.isConnectedToNetwork())
                {
                    let setlocapi = SetLocationAPI()
                    setlocapi.setCoOrdinates(completed: {}, coordinates: location, City: self.city)
                }else {
                    
                    
                }
                
                
            }
            
            
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

   
}

