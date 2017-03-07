//
//  FreindRequestNotificationVC.swift
//  MakeMePopular
//
//  Created by Mac on 25/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

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

class FreindRequestNotificationVC: UIViewController {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var reject: UIButton!
    
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var close: UIImageView!
    
    var type:String = ""
    var msg:String = ""
    var friendId:String = ""
    var notifid:String = ""
    var thumbnailURl:String = ""
    var username:String = ""
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        checkNotif()
        setUPView()
        
    }
    
    
    
    func checkNotif(){
        let pref = UserDefaults.standard
        
        type = pref.string(forKey: "Type")!
        msg = pref.string(forKey: "MessageText")!
        friendId = pref.string(forKey: "SenderID")!
        notifid = pref.string(forKey: "NotifId")!
        thumbnailURl = pref.string(forKey: "NotiURL")!
        username = pref.string(forKey: "NotiUserName")!
        
        messageText.text = msg
        print(username)
        print(thumbnailURl)
        
    }
    
    func setUPView(){
        let utils = Utils()
        
        accept.layer.cornerRadius = 7
        accept.layer.shadowOpacity = 0.5
        accept.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        accept.layer.shadowRadius = 5.0
        accept.layer.shadowColor = UIColor.black.cgColor
        
        reject.layer.cornerRadius = 7
        reject.layer.shadowOpacity = 0.5
        reject.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        reject.layer.shadowRadius = 5.0
        reject.layer.shadowColor = UIColor.black.cgColor
        
      
        
        mainview.layer.cornerRadius = 7
        mainview.clipsToBounds = true
        mainview.layer.borderWidth = 3
        mainview.layer.borderColor = utils.hexStringToUIColor(hex: "32A7B6").cgColor
        
        close.image = UIImage.fontAwesomeIcon(name: .close, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(NotificationVC.didCloseTap))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        close.isUserInteractionEnabled = true
        close.addGestureRecognizer(singleTap2)
        
        userPic.layer.cornerRadius = 26
        userPic.clipsToBounds = true
        
        let v = username
        let stArr = v.components(separatedBy: " ")
        var st=""
        for s in stArr{
            if let str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        let imgText = ImageToText()
        userPic.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        
            if(thumbnailURl != ""){
                let downloadImg = DownloadImage()
                downloadImg.setImage(imageurlString: thumbnailURl, imageView: userPic)
            }
        

    }
    
    func didCloseTap(){
        self.dismiss(animated: true, completion: {})
    }
    
    
      @IBAction func acceptClick(_ sender: Any) {
        if(Reachability.isConnectedToNetwork()){
            acceptrejectFriendRequest(completed: {}, isaccept: true)
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
            acceptrejectFriendRequest(completed: {}, isaccept: false)
            
        }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

    }
    
   
    
    
    func acceptrejectFriendRequest(completed: DownloadComplete,isaccept:Bool){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "AcceptRejectFriendRequest"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        var requestsat = "accepted"
        if(isaccept == false){
            requestsat = "rejected"
        }
        
        let current_url = URL(string: Current_Url)!
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        let parameters1 = ["userId":userId,"friendId":friendId,"isEmergencyContact":false,"isAccept":isaccept,"notificationId":notifid] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
            
            let respo = response.response?.statusCode
            
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if(respo == 200)
            {
                
                let msgSend = UIAlertController(title: "Friend Request", message: "Friend Request " + requestsat + " succefully", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel){
                    UIAlertAction in
                    self.dismiss(animated: false, completion: nil)
                }
                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true, completion: {  })
            }
            else{
                
                let msgSend = UIAlertController(title: "Friend Request", message: "Friend Request failed", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true, completion: {  })
                
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


