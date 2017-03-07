//
//  NotificationDetailVC.swift
//  MakeMePopular
//
//  Created by Mac on 03/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class NotificationDetailVC: UIViewController {
    
    @IBOutlet weak var dateTypeV: UIView!
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnaccept: UIButton!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var notifDate: UILabel!
    @IBOutlet weak var notifType: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var back: UIImageView!
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    fileprivate var _notification: NotificationModel!
    var notificationModel: NotificationModel
        {
        
        get{
            return _notification
        }
        set
        {
            _notification = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpView()
    }
    
    func setUpView(){
        
        let utils = Utils()
        
        utils.createGradientLayer(view: self.view)
        
        btnaccept.layer.cornerRadius = 4
        btnaccept.layer.shadowOpacity = 0.5
        btnaccept.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        btnaccept.layer.shadowRadius = 5.0
        btnaccept.layer.shadowColor = UIColor.black.cgColor
        
        btnReject.layer.cornerRadius = 4
        btnReject.layer.shadowOpacity = 0.5
        btnReject.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        btnReject.layer.shadowRadius = 5.0
        btnReject.layer.shadowColor = UIColor.black.cgColor
        
        btnMap.layer.cornerRadius = 4
        btnMap.layer.shadowOpacity = 0.5
        btnMap.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        btnMap.layer.shadowRadius = 5.0
        btnMap.layer.shadowColor = UIColor.black.cgColor
        
        btnaccept.isHidden = true
        btnReject.isHidden = true
        btnMap.isHidden = true
        
        messageText.layer.cornerRadius = 5
        messageText.clipsToBounds = true
        //messageText.layer.borderWidth = 3
       // messageText.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor
        dateTypeV.layer.cornerRadius = 5
        dateTypeV.clipsToBounds = true
        dateTypeV.layer.borderWidth = 1
        dateTypeV.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor
        
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 45))
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(NotificationDetailVC.didBackTapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap)
        
        
        if(_notification.isReceived == true){
            
            if(_notification.notiType == "FriendRequest" && _notification.isRead == false){
                btnaccept.isHidden = false
                btnReject.isHidden = false
                btnaccept.setTitle("Accept", for: .normal)
                btnReject.setTitle("Reject", for: .normal)
            }
            else if(_notification.notiType == "Emergency" && _notification.isRead == false){
                btnaccept.isHidden = false
                btnReject.isHidden = false
                btnMap.isHidden = false
                btnaccept.setTitle("Acknowledge", for: .normal)
                btnReject.setTitle("Ignore", for: .normal)

            }
        }
        
        notifType.text = _notification.notiType
        messageText.text = _notification.notiText
        userName.text = _notification.notiFromUserName
        
        userPic.layer.cornerRadius = 31
        userPic.clipsToBounds = true
        
        print("\(_notification.notiTime)")
        let timeStampArr:[String] = (_notification.notiTime?.components(separatedBy: "T"))!
        let dateArr:[String] = timeStampArr[0].components(separatedBy: "-")
        let dateStr = dateArr[2]+"/"+dateArr[1]+"/"+dateArr[0]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd/MM/yyyy"
        
        let dateD = dateFormatter1.date(from: dateStr)
        let dateFinal = dateFormatter.string(from: dateD!)
        
        notifDate.text = dateFinal
        
        
        let v = userName.text
        let stArr = v?.components(separatedBy: " ")
        var st=""
        for s in stArr!{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        let imgText = ImageToText()
        userPic.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        if(_notification.notiFromThumbnailUrl != nil){
            if(_notification.notiFromThumbnailUrl != ""){
                let downloadImg = DownloadImage()
                downloadImg.setImage(imageurlString: _notification.notiFromThumbnailUrl!, imageView: userPic)
            }
        }
    }
    
    func didBackTapDetected() {
        
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func btnMapClick(_ sender: Any) {
        if(Reachability.isConnectedToNetwork()){
        acceptrejectEmergencyRequest(completed: {}, isreach: true,isShoeMAp: true)
        }
        else{
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            

        }
        
    }
    @IBAction func btnAcceptClick(_ sender: Any) {
        if(Reachability.isConnectedToNetwork()){
        if(_notification.isReceived == true){
            
            if(_notification.notiType == "FriendRequest" && _notification.isRead == false){
                
                acceptrejectFriendRequest(completed: {}, isaccept: true)
                            }
            else if(_notification.notiType == "Emergency" && _notification.isRead == false){
               
                acceptrejectEmergencyRequest(completed: {}, isreach: true,isShoeMAp: false)
            }
         }
        }
        else{
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            

        }
    }
    @IBAction func btnRejectClick(_ sender: Any) {
        if(Reachability.isConnectedToNetwork()){
        if(_notification.isReceived == true){
            
            if(_notification.notiType == "FriendRequest" && _notification.isRead == false){
                
                acceptrejectFriendRequest(completed: {}, isaccept: false)
            }
            else if(_notification.notiType == "Emergency" && _notification.isRead == false){
                
                
                acceptrejectEmergencyRequest(completed: {}, isreach: false,isShoeMAp: false)
            }
          }
        }
        else{
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
        
        let parameters1 = ["userId":userId,"friendId":_notification.notiFromUserId!,"isEmergencyContact":false,"isAccept":isaccept,"notificationId":_notification.notificationId!] as [String : Any]
        
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
                    self.dismiss(animated: true, completion: nil)
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
    
    
    func acceptrejectEmergencyRequest(completed: DownloadComplete,isreach:Bool,isShoeMAp:Bool){
        
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
        
        let parameters1 = ["userId":userId,"friendId":_notification.notiFromUserId!,"message":"","isReaching":isreach,"notificationId":_notification.notificationId!] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
            
            let respo = response.response?.statusCode
            
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if(respo == 200)
            {
                if(isShoeMAp == true){
                    let pref = UserDefaults.standard
                    pref.set(self._notification.notiFromUserId, forKey: "FriendSID")
                    pref.set("", forKey: "Interest")
                    pref.set(true, forKey: "Route")
                    pref.synchronize()
                    
                    self.performSegue(withIdentifier: "nearme", sender: nil)
                }
                else{
                let msgSend = UIAlertController(title: "Emergency Request", message: "Emergency Request " + requestsat, preferredStyle: .alert)
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel)
                {
                    UIAlertAction in
                    self.dismiss(animated: false, completion: {})
                    
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
                    self.dismiss(animated: false, completion: {})
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
        self.spinner.stopAnimating()
        self.loadingView.removeFromSuperview()
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }

    
        
}

