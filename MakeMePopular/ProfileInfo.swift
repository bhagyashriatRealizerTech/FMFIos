//
//  ProfileInfo.swift
//  MakeMePopular
//
//  Created by Mac on 01/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper


class ProfileInfo: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var mobValue: UILabel!
    @IBOutlet weak var mobPic: UIImageView!
    @IBOutlet weak var dateValue: UILabel!
    @IBOutlet weak var datePic: UIImageView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailPic: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var back: UIImageView!
    var profPicString:String = ""
    let imagePicker = UIImagePickerController()
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
        imagePicker.delegate = self
        setUPView()
        
    }
    
    func setUPView()  {
        
        let dob:String = UserDefaults.standard.value(forKey: "BirthDate") as! String
        let emailid:String = UserDefaults.standard.value(forKey: "EmailID") as! String
        let mobno:String = UserDefaults.standard.value(forKey: "MobNo") as! String
        let fname:String = UserDefaults.standard.value(forKey: "UserFName") as! String
        let lname:String = UserDefaults.standard.value(forKey: "UserLName") as! String
        let thumbnailUrl:String = UserDefaults.standard.value(forKey: "ProfilePic") as! String
        
        username.text = fname + " " + lname
        dateValue.text = getLocalDate(utcDate: dob)
        email.text = emailid
        mobValue.text = mobno
        
        let utils = Utils()
        
        utils.createGradientLayer(view: self.view)
        
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 45, height: 45))
        
        datePic.image = UIImage.fontAwesomeIcon(name: .birthdayCake, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        
        emailPic.image = UIImage.fontAwesomeIcon(name: .envelope, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        
        mobPic.image = UIImage.fontAwesomeIcon(name: .phoneSquare, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        
        
        let singleTapP = UITapGestureRecognizer(target: self, action: #selector(ProfileInfo.didTapDetected))
        singleTapP.numberOfTapsRequired = 1 // you can change this value
        profilepic.isUserInteractionEnabled = true
        profilepic.addGestureRecognizer(singleTapP)
        
        
        
        let v = username.text
        let stArr = v?.components(separatedBy: " ")
        var st=""
        for s in stArr!{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        let imgText = ImageToText()
        profilepic.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        
       let newURl = thumbnailUrl.replacingOccurrences(of: "/small", with: "")
        print(newURl)
            if(newURl != ""){
                let downloadImg = DownloadImage()
                downloadImg.setImage(imageurlString: newURl, imageView: profilepic)
            
        }
        
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ProfileInfo.didTapBack))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap)
        
       
    }
    
    func didTapDetected() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func didTapBack(){
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector:#selector(ProfileInfo.recievedNotification), name: NSNotification.Name(rawValue: "recievednotif"), object: nil)
    }
    
    func recievedNotification(){
        
        let pref = UserDefaults.standard
        
        let type:String = pref.string(forKey: "Type")!
        let msg:String = pref.string(forKey: "MessageText")!
        
        if(type == "FriendRequest")
        {
            let storyboardName = "Main"
            let viewControllerID = "FriendRequest"
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            
            let controller:UIViewController = storyboard.instantiateViewController(withIdentifier: viewControllerID)
            self.present(controller, animated: true, completion: nil)
            
        }
        else if(type == "Emergency")
        {
            let storyboardName = "Main"
            let viewControllerID = "EmergencyNotif"
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            
            let controller:UIViewController = storyboard.instantiateViewController(withIdentifier: viewControllerID)
            self.present(controller, animated: true, completion: nil)
        }
        if(type == "FriendRequestAccepted")
        {
            let msgSend = UIAlertController(title: "Friend Request", message: msg, preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
        }
        else if(type == "FriendRequestRejected")
        {
            let msgSend = UIAlertController(title: "Friend Request", message: msg, preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
        }
        if(type == "EmergencyRecipt")
        {
            let msgSend = UIAlertController(title: "Emergency", message: msg, preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
        }
        else if(type == "TrackingRequest")
        {
            let msgSend = UIAlertController(title: "Track Request", message: msg, preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
        }
        if(type == "ApproveTracking")
        {
            let msgSend = UIAlertController(title: "Track Request", message: msg, preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
        }
        else if(type == "TrackingStarted")
        {
            let msgSend = UIAlertController(title: "Tracking", message: msg, preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
    
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profilepic.backgroundColor = UIColor.gray
            self.profilepic.layer.cornerRadius = 40
            self.profilepic.clipsToBounds = true
            self.profilepic.image = pickedImage
            
            
            
            if let imageData = pickedImage.jpeg(.medium) {
                if((imageData.count/1024) < 1000){
                    profPicString = imageData.base64EncodedString(options: .lineLength64Characters)
                    print("\(imageData.count/1024)")
                    
                    setProfilePic {}
                }
                else{
                    if let imageData1 = pickedImage.jpeg(.low) {
                        if((imageData1.count/1024) < 1000){
                            profPicString = imageData1.base64EncodedString(options: .lineLength64Characters)
                             print("\(imageData.count/1024)")
                            setProfilePic {}
                        }
                    }
                    else{
                    let credentialerror = UIAlertController(title: "Profile", message: "Please select smaller profile pic", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    
                    credentialerror.addAction(cancelAction)
                    self.present(credentialerror, animated: true, completion: {  })
                    }
                }
            }
            
            
        } else {
            
            //profileImage.image = nil
            print("Error occured")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func setProfilePic(completed: DownloadComplete){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "udpdateThumbanil"
        Current_Url = "\(ACCOUNT_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        var userId = ""
        userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        let parameters1 = ["userId":userId,"thumbanilBase64":profPicString] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        print(profPicString)
        
        Alamofire.request(current_url, method: .put, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            let respo = response.response?.statusCode
            
             self.view.isUserInteractionEnabled = true
             self.hideActivityIndicator()
            
            if(respo == 200)
            {
                let result = response.result
                if let dict = result.value as? [String: AnyObject]
                {
                    
                    let res = Mapper<UserDetail>().map(JSONObject: dict)
                    let pref = UserDefaults.standard
                    pref.set(res?.thumbnailUrl, forKey: "ProfilePic")
                    pref.synchronize()
                    
                }
            }
            else{
               
                let credentialerror = UIAlertController(title: "Profile", message: "Profile picture not set", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
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
    
    func getLocalDate(utcDate:String) -> String{
        let tempDate:String = utcDate.components(separatedBy: ".")[0]
        var localDate:String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let date = dateFormatter.date(from: tempDate)// create   date from string
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.timeZone = TimeZone.current
        localDate = dateFormatter.string(from: date!)
        return localDate
    }
    
    
    
    
    
}


