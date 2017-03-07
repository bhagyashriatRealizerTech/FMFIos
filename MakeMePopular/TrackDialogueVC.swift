//
//  TrackDialogueVC.swift
//  MakeMePopular
//
//  Created by Mac on 24/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class TrackDialogueVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var noData: UITextView!
    @IBOutlet weak var distanceSlider: CustomSlider!
    @IBOutlet weak var optionFriend: UIImageView!
    @IBOutlet weak var close: UIImageView!
    @IBOutlet weak var proceed: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var optionPossibilities: UIImageView!
    
    @IBOutlet weak var mainView: UIView!
    var isoption1Check:Bool!
    var interest:String = ""
    var friendId:String = ""
    var favOption = [InterestListModel]()
    var friendList = [FriendListModel]()
    var distance = 25
    var listCount = 0
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()

        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        distanceSlider.value = 25
        
        distance = Int(distanceSlider.value)
        UserDefaults.standard.set(distance, forKey: "Distance")
        UserDefaults.standard.synchronize()
        
        noData.isHidden = true
        
        
    }
    
    func setUpView(){
        
        isoption1Check = true
    
        changeCheck(isr1Check: isoption1Check)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(TrackDialogueVC.didOption1Tap))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        optionFriend.isUserInteractionEnabled = true
        optionFriend.addGestureRecognizer(singleTap)
        
       
        
     let singleTap1 = UITapGestureRecognizer(target: self, action: #selector(TrackDialogueVC.didOption2Tap))
        singleTap1.numberOfTapsRequired = 1 // you can change this value
        optionPossibilities.isUserInteractionEnabled = true
        optionPossibilities.addGestureRecognizer(singleTap1)
        
        let utils = Utils()
        pickerView.layer.borderWidth = 1
        pickerView.layer.borderColor = utils.hexStringToUIColor(hex: "32A7B6").cgColor
        
        optionFriend.layer.borderColor = utils.hexStringToUIColor(hex: "32A7B6").cgColor
        optionFriend.layer.borderWidth = 2
        
        optionPossibilities.layer.borderWidth = 2
        optionPossibilities.layer.borderColor = utils.hexStringToUIColor(hex: "32A7B6").cgColor
        
        
        proceed.layer.cornerRadius = 5
        proceed.layer.shadowOpacity = 0.5
        proceed.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        proceed.layer.shadowRadius = 5.0
        proceed.layer.shadowColor = UIColor.black.cgColor
        
        mainView.layer.cornerRadius = 5
        mainView.clipsToBounds = true
        mainView.layer.borderWidth = 3
        mainView.layer.borderColor = utils.hexStringToUIColor(hex: "32A7B6").cgColor
        
        close.image = UIImage.fontAwesomeIcon(name: .close, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(TrackDialogueVC.didCloseTap))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        close.isUserInteractionEnabled = true
        close.addGestureRecognizer(singleTap2)
        
        self.mainView.backgroundColor = UIColor.white
        
        //utils.createGradientLayer(view: self.mainView)
        
    }
    
    func changeCheck(isr1Check:Bool){
        let utils = Utils()
        
        if(isr1Check == true){
            let utils = Utils()
            distanceSlider.isHidden = true
            distanceSlider.label.isHidden = true
            self.optionFriend.backgroundColor = utils.hexStringToUIColor(hex: "00BCD4")
            self.optionFriend.layer.cornerRadius = 10
            self.optionFriend.clipsToBounds = true
            self.optionFriend.image = UIImage.fontAwesomeIcon(name: .users, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 60, height: 60))
            
            self.optionPossibilities.backgroundColor = utils.hexStringToUIColor(hex: "ffffff")
            self.optionPossibilities.layer.cornerRadius = 10
            self.optionPossibilities.clipsToBounds = true
            self.optionPossibilities.image = UIImage.fontAwesomeIcon(name: .userPlus, textColor: utils.hexStringToUIColor(hex: "00BCD4"), size: CGSize(width: 60, height: 60))
            
            
            
            if(friendList.count == 0)
            {
                if(Reachability.isConnectedToNetwork()){
                   getFriendList {}
                }
                else {
                    
                    let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    
                    credentialerror.addAction(cancelAction)
                    self.present(credentialerror, animated: true, completion: {  })
                    
                }

            }
            else{
                
                self.listCount = self.friendList.count
                
                self.pickerView.delegate = self
                self.pickerView.dataSource = self
                self.pickerView.reloadAllComponents()
                
                interest = ""
                friendId = friendList[0].friendsUserId!
                
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
            }
           
            
        }else{
            distanceSlider.isHidden = false
            distanceSlider.label.isHidden = false
            self.optionFriend.backgroundColor = utils.hexStringToUIColor(hex: "ffffff")
            self.optionFriend.layer.cornerRadius = 10
            self.optionFriend.clipsToBounds = true
            self.optionFriend.image = UIImage.fontAwesomeIcon(name: .users, textColor: utils.hexStringToUIColor(hex: "00BCD4"), size: CGSize(width: 60, height: 60))
            
            self.optionPossibilities.backgroundColor = utils.hexStringToUIColor(hex: "00BCD4")
            self.optionPossibilities.layer.cornerRadius = 10
            self.optionPossibilities.clipsToBounds = true
            self.optionPossibilities.image = UIImage.fontAwesomeIcon(name: .userPlus, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 60, height: 60))
            if(favOption.count == 0)
            {
                if(Reachability.isConnectedToNetwork()){
                     getUserInterest {}
                }
                else {
                    
                    let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    
                    credentialerror.addAction(cancelAction)
                    self.present(credentialerror, animated: true, completion: {  })
                    
                }
               
            }
            else{
                self.listCount = self.favOption.count
                
                self.pickerView.delegate = self
                self.pickerView.dataSource = self
                self.pickerView.reloadAllComponents()
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
                friendId = ""
                interest = favOption[0].interestName!
            }
            
            
        }
        
        
    }
    
    func didCloseTap(){
        self.dismiss(animated: true, completion: {})
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    func didOption1Tap() {
        
        if(isoption1Check == false)
       {
            isoption1Check = true
            changeCheck(isr1Check: isoption1Check)
        }
        
    }
    
    func didOption2Tap() {
        
        if(isoption1Check == true)
        {
            isoption1Check = false
            changeCheck(isr1Check: isoption1Check)
        }
    }
    
    func getUserInterest(completed: DownloadComplete){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "GetGeneralInterestList/"
        let userID = UserDefaults.standard.value(forKey: "UserID") as! String
        Current_Url = "\(BASE_URL)\(methodName)\(userID)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        print(current_url)
        
        Alamofire.request(current_url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON{ response in
            
            let respo = response.response?.statusCode
            let result = response.result
            
            if(respo == 200)
            {
                
                let res = Mapper<InterestListModel>().mapArray(JSONObject: result.value)
                self.listCount = (res?.count)!
                if((res?.count)! > 0){
                    self.pickerView.isHidden = false
                    self.noData.isHidden = true
            
                    self.favOption = res!
                    self.pickerView.delegate = self
                    self.pickerView.dataSource = self
                    self.pickerView.reloadAllComponents()
                    
                    if(self.isoption1Check == false){
                        
                        self.interest = self.favOption[0].interestName!
                        self.friendId = ""
                    }
                }
                else{
                    self.pickerView.isHidden = true
                    self.noData.isHidden = false
                    self.noData.text = "You have selected no interests. Please select interest first"
                }
                
            }
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
        }
        
        completed()
    }
    
    
    func getFriendList(completed: DownloadComplete){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "getFriendList"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        let parameters1 = ["userId":userId,"searchText":""] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            let respo = response.response?.statusCode
            let result = response.result
            print("\(result.value)")
            if(respo == 200)
            {
                
                let res = Mapper<FriendListModel>().mapArray(JSONObject: result.value)
                self.friendList.removeAll()
               
                if((res?.count)! > 0){
                    for i in 0...((res?.count)! - 1)
                    {
                        if(res?[i].status == "Accepted")
                        {
                        self.friendList.append((res?[i])!)
                        }
                    }
                    self.listCount = self.friendList.count
                    
                    if(self.friendList.count > 0){
                        let frnd = FriendListModel()
                        frnd.setupValue(friendName1: "All")
                        self.friendList.append(frnd)
                    }
                    self.pickerView.isHidden = false
                    self.noData.isHidden = true
                    self.pickerView.delegate = self
                    self.pickerView.dataSource = self
                    self.pickerView.reloadAllComponents()
                    
                    if(self.friendList.count > 0){
                    if(self.isoption1Check == true){
                        
                        self.interest = ""
                        if(self.friendList[0].friendName == "All"){
                            self.friendId = "All"
                        }
                        else{
                            self.friendId = self.friendList[0].friendsUserId!
                        }
                        
                      }
                    }
                }
                else{
                    self.pickerView.isHidden = true
                    self.noData.isHidden = false
                    self.noData.text = "You have added no friends. Please add friends first"
                }
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
                
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Track", message: "Failed to fetch friend list, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(isoption1Check == true)
        {
            return friendList.count
        }
        else{
            return favOption.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        let utils = Utils()
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Avenir", size: 13)
            pickerLabel?.textAlignment = NSTextAlignment.center
            pickerLabel?.textColor = utils.hexStringToUIColor(hex: "000000")
            
            if(isoption1Check == true){
                pickerLabel?.text = friendList[row].friendName
                
            }
            else{
                pickerLabel?.text = favOption[row].interestName
            }
        }
        
        return pickerLabel!;
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(isoption1Check == true)
        {
            return friendList[row].friendName
            
        }
        else{
            return favOption[row].interestName
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if(isoption1Check == true){
            
            interest = ""
            if(friendList.count > 0)
            {
            if(friendList[row].friendName == "All"){
               friendId = "All"
            }
            else{
            friendId = friendList[row].friendsUserId!
             }
            }
        }
        else{
            if(favOption.count > 0){
            interest = favOption[row].interestName!
            friendId = ""
            }
        }
        
    }


    
    @IBAction func proceedClick(_ sender: Any) {
        if(listCount > 0){
        if(friendId == "" && interest == ""){
            let msgSend = UIAlertController(title: "Near Me", message: "Please select friend or interest to proceed", preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
        }
        else{
        let pref = UserDefaults.standard
        pref.set(friendId, forKey: "FriendSID")
        pref.set(interest, forKey: "Interest")
        pref.synchronize()
        
        self.performSegue(withIdentifier: "nearmefriend", sender: self)
            
        }
      }
        else{
            let msgSend = UIAlertController(title: "Near Me", message: "No  friend or interest available to proceed", preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
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
    
    override func viewWillAppear(_ animated: Bool) {
    
        NotificationCenter.default.addObserver(self, selector:#selector(TrackDialogueVC.recievedNotification), name: NSNotification.Name(rawValue: "recievednotif"), object: nil)
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
    

    @IBAction func distanceSlideTap(_ sender: CustomSlider) {
        
       distance = Int(sender.label.text!)!
        
        UserDefaults.standard.set(distance, forKey: "Distance")
        UserDefaults.standard.synchronize()
    }

}

