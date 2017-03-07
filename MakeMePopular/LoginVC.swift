//
//  LoginVC.swift
//  MakeMePopular
//
//  Created by sachin shinde on 11/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import TextFieldEffects
import Alamofire
import ObjectMapper
import FirebaseInstanceID
import FirebaseMessaging
import Firebase
import GoogleMaps

class LoginVC: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var gradientLayer: CAGradientLayer!
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var mobileno: JiroTextField!
    @IBOutlet weak var signup: UILabel!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var topImage: UIImageView!
    var dbth=DBThreadList()
    var friend1=FriendListDetail()
    var dbmsg=DBMessageList()
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        setView()
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(LoginVC.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("\(locValue.latitude)")
    }

    
    func setView()
    {
        submit.layer.shadowOpacity = 0.5
        submit.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        submit.layer.shadowRadius = 5.0
        submit.layer.shadowColor = UIColor.black.cgColor
        submit.layer.cornerRadius = 10
        //submit.clipsToBounds = true
        
        let utils = Utils()
        
        headerImage.image = UIImage.fontAwesomeIcon(name: .phone, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 40))
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.didTapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        signup.isUserInteractionEnabled = true
        signup.addGestureRecognizer(singleTap)
        
        
    }
    
    
    func didTapDetected() {
        performSegue(withIdentifier: "register", sender: self)
    }
    
    

    func didTapView(){
        self.view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        //let utils = Utils()
       // utils.createGradientLayer(view: self.view)
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = #imageLiteral(resourceName: "login_back")
        backgroundImage.contentMode = UIViewContentMode.scaleToFill
        self.view.insertSubview(backgroundImage, at: 0)

        //self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "login_back"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func submitClick(_ sender: Any) {
        
       
        dbth.deleteallvalues()
        friend1.deleteallvalues()
        dbmsg.deleteallvalues()
//        getFriendList {
//                }
        locationManager.stopUpdatingLocation()
        
        if(mobileno.text != nil){
            
         if(!(mobileno.text!.isEmpty)){
            
            if(Reachability.isConnectedToNetwork()){
              
           let mobno:String = mobileno.text! as String
           var refreshedToken = ""
           if(FIRInstanceID.instanceID().token() != nil){
            
            refreshedToken = FIRInstanceID.instanceID().token()!
            print("InstanceIdToken: \(refreshedToken)")
            
            let pref = UserDefaults.standard
            pref.set(refreshedToken, forKey: "FCMToken")
            pref.synchronize()
            connectToFCM()
            
            
            
            self.showActivityIndicator()
              loginUser(completed: {}, mobileno: mobno)
            
              }
             else{
               if(FIRInstanceID.instanceID().token() != nil){
                
                refreshedToken = FIRInstanceID.instanceID().token()!
                print("InstanceIdToken: \(refreshedToken)")
                
                let pref = UserDefaults.standard
                pref.set(refreshedToken, forKey: "FCMToken")
                pref.synchronize()
                connectToFCM()
                
                self.showActivityIndicator()
                loginUser(completed: {}, mobileno: mobno)
                
            }
                  }
            
               }
            else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
                }
            
            
            }
            
         else{
            let noMobileNo = UIAlertController(title: "Login Error", message: "Please enter your Mobile number", preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            noMobileNo.addAction(cancleAction)
            present(noMobileNo, animated: true, completion: {  })
            }
        }
        else{
            let noMobileNo = UIAlertController(title: "Login error", message: "Please enter your Mobile number", preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            noMobileNo.addAction(cancleAction)
            present(noMobileNo, animated: true, completion: {  })
        }
        
    }
    
    func getFriendList(completed: @escaping DownloadComplete)
    {
        let friend1=FriendListDetail()
        
    
               let methodName = "getFriendList"
        Current_Url = "\(BASE_URL)\(methodName)"
        
        
        let current_url = URL(string: Current_Url)!
        let time=friend1.getupdateddateoffriend()
        
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        var parameters1 = ["userId":userId,"searchText":"","lastUpdatedDate":time] as [String : Any]
        if(time=="")
        {
            parameters1=["userId":userId,"searchText":""] as [String : Any]
            
        }
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            
            let result = response.result
            
            
            if let dict = result.value  as?  [Dictionary<String,AnyObject>]
                
            {
                let res = Mapper<FriendListModel>().mapArray(JSONObject: dict)
                
                
                if((res?.count)! > 0)
                {
                    for i in 0...((res?.count)! - 1)
                    {
                        let msg = res?[i]
                        let isfriend:Bool=friend1.getfriends(friendId: (msg?.friendsUserId)!)
                        if(isfriend == true)
                        {
                            
                            
                            //update....
                            
                        }
                            
                        else{
                            
                            friend1.insertfriendlist(friendlist: msg!)
                            
                        }
                    }
                }
                    
                else { }
                
                
                
                
            }
            
            completed()
        }
    }

    
    func loginUser(completed: DownloadComplete, mobileno:String){
        
        self.view.isUserInteractionEnabled = false
        
        let methodName = "CheckUser"
        Current_Url = "\(ACCOUNT_URL)\(methodName)"
        print(Current_Url)
        let regToken:String = UserDefaults.standard.value(forKey: "FCMToken") as! String
        let current_url = URL(string: Current_Url)!
        let parameters1 = ["contactNo":mobileno,"fcmId":regToken] as [String : Any]
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            print("\(response.response?.statusCode)")
      if(response.response!.statusCode == 200)
        {
            let result = response.result
            if let dict = result.value as? [String: AnyObject]
            {
                let res = Mapper<UserDetail>().map(JSONObject: dict)
                
                if(res?.userId == "00000000-0000-0000-0000-000000000000"){
                  
                    self.view.isUserInteractionEnabled = true
                    self.hideActivityIndicator()
                    let credentialerror = UIAlertController(title: "Login", message: "Login Failed, please try after some time", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    
                    credentialerror.addAction(cancelAction)
                    self.present(credentialerror, animated: true, completion: {  })
                    
                }
                else{
                
                let pref = UserDefaults.standard
                pref.set(res?.fName, forKey: "UserFName")
                    
                pref.set(res?.lName, forKey: "UserLName")
                 
                pref.set(res?.thumbnailUrl, forKey: "ProfilePic")
                pref.set(res?.gender, forKey: "Gender")
                pref.set(res?.userId, forKey: "UserID")
                pref.set(true, forKey: "IsLogin")
                pref.set(res?.dob, forKey: "BirthDate")
                pref.set(res?.emailId, forKey: "EmailID")
                pref.set(res?.contactNo, forKey: "MobNo")
               pref.set(res?.ChatBadgeCount, forKey: "ChatCount")
             pref.set(res?.FriendBadgeCount, forKey: "FriendCount")
                if(res?.todayTrackedCount != nil){
                   pref.setValue(res?.todayTrackedCount, forKey: "TodayTrack")
                }
                else{
                    pref.setValue("0", forKey: "TodayTrack")
                }
                
                if(res?.lastWeekTrackedCount != nil){
                    pref.setValue(res?.lastWeekTrackedCount, forKey: "LastWeek")
                }
                else{
                    pref.setValue("0", forKey: "LastWeek")
                }
                
                if(res?.lastMonthTrackedCount != nil){
                    pref.setValue(res?.lastMonthTrackedCount, forKey: "LastMonth")
                }
                else{
                    pref.setValue("0", forKey: "LastMonth")
                }
                
                
                print("\(res?.thumbnailUrl)")
                pref.synchronize()
                
                self.view.isUserInteractionEnabled = true
                
                self.hideActivityIndicator()
                    self.getFriendList {
                     
                    }
                self.performSegue(withIdentifier: "logintodashboard", sender: self)
                }
            }
        }
      else{
        self.view.isUserInteractionEnabled = true
              self.hideActivityIndicator()
        let credentialerror = UIAlertController(title: "Login", message: "Login Failed, please try after some time.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
        
        credentialerror.addAction(cancelAction)
        self.present(credentialerror, animated: true, completion: {  })
        
            }
        
    }
        
        completed()
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
    
    func showActivityIndicator() {
        
        // UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DispatchQueue.main.async {
            let utils = Utils()
            
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = utils.hexStringToUIColor(hex: "32A7B6")
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            
            let actInd = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            actInd.color = utils.hexStringToUIColor(hex: "ffffff")
            self.spinner = actInd
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.spinner)
            self.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
            
        }
        
    }
    
    
    
    func hideActivityIndicator() {
        
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
    
    
}
