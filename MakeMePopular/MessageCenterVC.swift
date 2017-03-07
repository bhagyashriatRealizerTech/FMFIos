//
//  MessageCenterVC.swift
//  MakeMePopular
//
//  Created by sachin shinde on 08/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//


import UIKit
import Alamofire
import FontAwesome_swift
import CoreData
import ObjectMapper

@available(iOS 10.0, *)
class MessageCenterVC: UIViewController ,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate{
    
    var context:NSManagedObjectContext!
    @IBOutlet weak var textmsg: UITextField!
    
    
    
    @IBOutlet weak var hidelabel: UILabel!
    
    
    
    @IBOutlet weak var back: UIImageView!
    
    
    @IBOutlet weak var selectfriend: UIButton!
    
    
    
    @IBOutlet weak var selectfriendpicker: UIPickerView!
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    let friend1 = FriendListDetail()
    
    var contacts:[String] = []
    var clist=[ContactList]()
    var userid:String!
    
    @IBOutlet weak var sendbtn: UIButton!
    @IBAction func sendclick(_ sender: Any) {
        
        
        if(textmsg.text == "")
        {
            
            let initiateNewThread = UIAlertController(title: "Error", message: "Please enter message", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            
            
            initiateNewThread.addAction(cancelAction)
            
            
            self.present(initiateNewThread, animated: true, completion: {  })
            
        }
        else if(selectfriend.titleLabel?.text == "Select Friend")
        {
            dismissKeyboard()
            
            let initiateNewThread1 = UIAlertController(title: "Error", message: "Please select at least one user", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            
            
            initiateNewThread1.addAction(cancelAction)
            
            
            self.present(initiateNewThread1, animated: true, completion: {  })
            
        }
        else{
            
            downloadInitialThread {}
        }
        
        
    }
    
    @IBAction func selectfriendclick(_ sender: Any) {
        print("selectfriend")
        showActivityIndicator()
        if(clist.count < 0)
        {
            selectfriendpicker.isHidden=true
            hideActivityIndicator()
            hidelabel.text="No friends available in your friendlist"
            hidelabel.isHidden=false
        
        }
        else if(clist.count>0){
            
            selectfriendpicker.isHidden=false
            hideActivityIndicator()
            hidelabel.isHidden=true

        }
        else{
            selectfriendpicker.isHidden=true
            hideActivityIndicator()
            hidelabel.text="No result found"
            hidelabel.isHidden=false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(MessageCenterVC.didBackTapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap)
        
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.white, size: CGSize(width: 40, height: 45))
        
        self.showActivityIndicator()
        
        self.textmsg.delegate=self
        textmsg.layer.borderColor=UIColor.black.cgColor
        textmsg.layer.borderWidth=1
        textmsg.layer.cornerRadius=5
        
        getFriendList {}
        
        
        self.hideActivityIndicator()
        
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageCenterVC.dismissKeyboard))
        
        
        view.addGestureRecognizer(tap)
        
    }
    func didBackTapDetected() {
        
        self.dismiss(animated: true, completion: {})
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        animateViewMoving(up: true, moveValue: 260)
    }
    @IBOutlet weak var mview: UIView!
    @IBOutlet weak var headerview: UIView!
    @IBOutlet weak var buttontop: NSLayoutConstraint!
    func textFieldDidEndEditing(_ textField: UITextField) {
       sendclick(self)
        animateViewMoving(up: false, moveValue: 260)
       
        
    }
    @IBOutlet weak var hedertop: NSLayoutConstraint!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        dismissKeyboard()
        return true
    }
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        
        
        
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        
        
        UIButton.beginAnimations("animateView", context: nil )
        UIButton.setAnimationBeginsFromCurrentState(true)
        UIButton.setAnimationDuration(movementDuration )
        self.selectfriend.frame=self.selectfriend.frame.offsetBy(dx: 0, dy: 0)
        
        
        UITextField.beginAnimations("animateView", context: nil)
        UITextField.setAnimationBeginsFromCurrentState(true)
        UITextField.setAnimationDuration(movementDuration )
        self.textmsg.frame = self.textmsg.frame.offsetBy(dx: 0, dy: movement)
     
    

        self.sendbtn.frame=self.sendbtn.frame.offsetBy(dx: 0, dy: movement)
        
        
        UIView.beginAnimations( "animateView", context: nil)
        
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        
        self.headerview.frame = self.headerview.frame.offsetBy(dx: 0,  dy: 0)
        
        
        
        
                hidelabel.isHidden=true
        
        hedertop.constant=0
        buttontop.constant=0
        
        UITextField.commitAnimations()
        UIButton.commitAnimations()
        
        //UIView.commitAnimations()
    }
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func getFriendList(completed: @escaping DownloadComplete){
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
           
            if(response.response?.statusCode==200)
            {
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
                    
                   
                    self.clist.removeAll()
                    self.clist=friend1.retrivefriendlist()
                  
                    
                    print(self.clist)
                    self.contacts.removeAll()
                    if(!self.clist.isEmpty)
                    {
                    for i in 0...(self.clist.count-1){
                        
                        
                        self.clist.sort(){$0.username < $1.username}
                       let m = self.clist[i].username
                       
                        self.contacts.append(m)
                       
                    }
                    }
                    else{
                    self.selectfriendpicker.isHidden=true
                        self.hidelabel.isHidden=false
                    }
              
            }
            
            }
            
            if(self.clist.count > 0){
                self.selectfriendpicker.dataSource=self
                self.selectfriendpicker.delegate=self
                self.hideActivityIndicator()
            }
                
            else{
                self.hidelabel.isHidden=false
                self.selectfriendpicker.isHidden=true
                
            }
            
            
            
            self.hideActivityIndicator()
            completed()
        }
    }
    @available(iOS 10.0, *)
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func downloadInitialThread(completed: DownloadComplete){
        dismissKeyboard()
        showActivityIndicator()
       // friend1.deleteallvalues()
        let m = Chat_URL + "initiateThread"
        
        var a:[Dictionary<String,String>]=[]
        let m0 :Dictionary<String,String> = ["userId":userid]
        //print(userid)
        
        a.append(m0)
        let date = Date()
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let d:String=dateformatter.string(from: date)
        
        let msg:String = textmsg.text!
        let msgsenderid:String = UserDefaults.standard.value(forKey: "UserID") as! String
        
        
        
        let param:Parameters=["timeStamp":d,"lastSenderById":msgsenderid,"lastMessageText":msg,"participantList":a]
        
        var base_url:URL? = nil
        base_url = URL(string: m )
        
        Alamofire.request(base_url!,method: .post ,parameters:param,encoding:JSONEncoding.default).responseJSON{ response in
            
        
            self.hideActivityIndicator()
            
            
            self.hideActivityIndicator()
            
            self.dismiss(animated: true) {}
            
            
            
        }
        completed()
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contacts.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return contacts[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectfriend.setTitle(contacts[row], for: UIControlState())
       
   
        
        userid=clist[row].frienduserId
        
        selectfriendpicker.isHidden=true
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let  myView = UIView(frame: CGRect(x: 0, y: 0, width:pickerView.bounds.width-30 ,height: 30))
        
        let imgview:UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        
        
        let v = contacts[row]
        let stArr = v.components(separatedBy: " ")
        var st=""
        for s in stArr{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        if(clist[row].thumbnailurl.isEmpty)
        {
            let img = ImageToText()
            
            let tempimg = img.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "color"), atPoint: CGPoint(x: 20.0, y: 20.0))
            imgview.layer.borderColor = UIColor.gray.cgColor
            imgview.layer.cornerRadius = 15.7
            imgview.layer.masksToBounds = true
            imgview.image = tempimg
            
        }
        else{
            
            let imagedownload = DownloadImage()
            
            let profileimage = imagedownload.userImage(imageurlString: clist[row].thumbnailurl)
            if(profileimage != nil)
            {
                imgview.layer.borderColor = UIColor.gray.cgColor
                imgview.layer.cornerRadius = 15.7
                imgview.layer.masksToBounds = true
                imgview.image = profileimage
                
            }
            else
            {
                let img = ImageToText()
                let tempimg = img.textToImage(drawText: st as NSString, inImage:#imageLiteral(resourceName: "color"), atPoint: CGPoint(x: 20.0, y: 20.0))
                imgview.layer.borderColor = UIColor.gray.cgColor
                imgview.layer.cornerRadius = 15.7
                imgview.layer.masksToBounds = true
                imgview.image = tempimg
                
            }
            
        }
        
        
        let uname = contacts[row]
        
        let myLabel=UILabel(frame:(CGRect(x:100, y: 0, width: 200, height: 30)))
        
        
        myLabel.text = uname
        
        myView.addSubview(myLabel)
        
        myView.addSubview(imgview)
        return myView
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
    
    
    @IBAction func backbtnClicked(_ sender: AnyObject) {
        
        self.dismiss(animated: true) {
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.hidesBarsWhenKeyboardAppears = false
        if Reachability.isConnectedToNetwork() == true{
            
            
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            
            let uialert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            
            uialert.addAction(okAction)
            
            present(uialert, animated: true, completion: {  })
            
            hideActivityIndicator()
        }
        
    }
    
    
}
