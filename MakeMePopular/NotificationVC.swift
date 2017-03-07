//
//  NotificationVC.swift
//  MakeMePopular
//
//  Created by Mac on 24/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class NotificationVC: UIViewController {
    
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var map: UIButton!
    @IBOutlet weak var reject: UIButton!
    @IBOutlet weak var notificationTitle: UILabel!
    
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var close: UIImageView!
    
    var type:String = ""
    var msg:String = ""
    var friendId:String = ""
    var notifid:String = ""
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setUPView()
        checkNotif()

    
    }
    
 
    
    func checkNotif(){
        let pref = UserDefaults.standard
        
        type = pref.string(forKey: "Type")!
        msg = pref.string(forKey: "MessageText")!
        friendId = pref.string(forKey: "SenderID")!
        notifid = pref.string(forKey: "NotifId")!
        
        if(type == "Emergency"){
           
            self.reject.setTitle("Ignore", for: .normal)
        }
        
        messageText.text = msg
        
    }
    
    func setUPView(){
        let utils = Utils()
        
        reject.layer.cornerRadius = 7
        reject.layer.shadowOpacity = 0.5
        reject.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        reject.layer.shadowRadius = 5.0
        reject.layer.shadowColor = UIColor.black.cgColor
        
        map.layer.cornerRadius = 7
        map.layer.shadowOpacity = 0.5
        map.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        map.layer.shadowRadius = 5.0
        map.layer.shadowColor = UIColor.black.cgColor
        
        mainview.layer.cornerRadius = 7
        mainview.clipsToBounds = true
        mainview.layer.borderWidth = 3
        mainview.layer.borderColor = utils.hexStringToUIColor(hex: "DD2518").cgColor
        
        close.image = UIImage.fontAwesomeIcon(name: .close, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(NotificationVC.didCloseTap))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        close.isUserInteractionEnabled = true
        close.addGestureRecognizer(singleTap2)
        
    }
    
    func didCloseTap(){
        self.dismiss(animated: true, completion: {})
    }
    
    

    @IBAction func mapClick(_ sender: Any) {
        
        
        if(Reachability.isConnectedToNetwork()){
            let pref = UserDefaults.standard
            pref.set(friendId, forKey: "FriendSID")
            pref.set("", forKey: "Interest")
            pref.set(true, forKey: "Route")
            pref.synchronize()

            acceptrejectEmergencyRequest(completed: {}, isreach: true,isShowMap: true)
            
        }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

    }
    
    
   
    @IBAction func rejectClick(_ sender: Any) {
        
      
        if(Reachability.isConnectedToNetwork()){
            acceptrejectEmergencyRequest(completed: {}, isreach: false,isShowMap: false)

        }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

    }
    
    
    
    func acceptrejectEmergencyRequest(completed: DownloadComplete,isreach:Bool,isShowMap:Bool){
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "EmergencyAcknowledgement"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        var requestsat = "acknoledged"
        
        if(isreach == false){
            requestsat = "ignored"
        }

        
        let current_url = URL(string: Current_Url)!
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        let parameters1 = ["userId":userId,"friendId":friendId,"message":"","isReaching":isreach,"notificationId":notifid] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
            
            let respo = response.response?.statusCode
            
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if(respo == 200)
            {
                if(isShowMap == true){
                    self.performSegue(withIdentifier: "showmap", sender: nil)
                    
                }
                else{
                let msgSend = UIAlertController(title: "Emergency Request", message: "Emergency Request " + requestsat, preferredStyle: .alert)
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel)
                {
                    UIAlertAction in
                    self.dismiss(animated: true, completion: {})
                    
                }

                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true, completion: {})
              }
            }
            else{
                
                let msgSend = UIAlertController(title: "Emergency Request", message: "Emergency Request failed", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true){
                    UIAlertAction in
                    self.dismiss(animated: true, completion: {})
                }
                
            }
            
        }
        
        completed()
    }
    
    
    func showActivityIndicator() {
        
        // UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DispatchQueue.main.async {
            let utils = Utils()
            
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = utils.hexStringToUIColor(hex: "ffffff")
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            
            let actInd = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            actInd.color = utils.hexStringToUIColor(hex: "32A7B6")
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

