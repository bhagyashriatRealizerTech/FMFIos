//
//  FriendListVC.swift
//  MakeMePopular
//
//  Created by Mac on 17/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

//
// MARK: - Section Data Structure
//


class FriendListVC: UIViewController , UITableViewDataSource, UITableViewDelegate
{

    var sections = [FriendListModel]()
    var sentList = [FriendListModel]()
    var recievedList = [FriendListModel]()
    
    
    @IBOutlet weak var blocked: UIImageView!
    @IBOutlet weak var rejected: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoPending: UIImageView!
    @IBOutlet weak var legendInfoView: UIView!
    @IBOutlet weak var friendListTable: UITableView!
    
    @IBOutlet weak var filetrrequest: UISegmentedControl!
    @IBOutlet weak var filter: UIImageView!
    @IBOutlet weak var back: UIImageView!
    var isSentRequest:Bool!
    
    @IBOutlet weak var filterSegmentHeight: NSLayoutConstraint!
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()

    
    
    let segAttributes1: NSDictionary = [
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "Avenir", size: 20)!
    ]
    
    let segAttributes2: NSDictionary = [
        NSForegroundColorAttributeName: UIColor.green,
        NSFontAttributeName: UIFont(name: "Avenir", size: 20)!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        friendListTable.register(UINib(nibName: "HeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CollapsibleTableViewHeader")
        
        filetrrequest.setTitleTextAttributes((segAttributes1 as! [AnyHashable : Any]), for: .selected)
        
        filetrrequest.setTitleTextAttributes((segAttributes2 as! [AnyHashable : Any]), for: .normal)
        
        
        friendListTable.delegate = self
        friendListTable.dataSource = self
        
        filetrrequest.isHidden = true
        filterSegmentHeight.constant = 0
        
        setUpView()
        
       
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(FriendListVC.didBackTapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap)
        
        if(Reachability.isConnectedToNetwork()){
            self.showActivityIndicator()
        getFriendList{}
        }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }
        
        
        let utils = Utils()
        
        infoView.layer.cornerRadius = 4
        infoView.clipsToBounds = true
        infoView.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor
        infoView.layer.borderWidth = 2
        
        
        rejected.image = UIImage.fontAwesomeIcon(name: .userTimes, textColor: utils.hexStringToUIColor(hex: "DD2518"), size: CGSize(width: 35, height: 35))
        
        
        infoPending.image = UIImage.fontAwesomeIcon(name: .hourglass1, textColor: utils.hexStringToUIColor(hex: "7D898B"), size: CGSize(width: 35, height: 35))
        
        
        blocked.image = UIImage.fontAwesomeIcon(name: .timesCircle, textColor: utils.hexStringToUIColor(hex: "DD2518"), size: CGSize(width: 35, height: 35))
        


        
    }
    
    func setUpView(){
        let utils = Utils()
        
        utils.createGradientLayer(view: self.view)
        
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 45, height: 40))
        
        isSentRequest = false
        
        
    }
    
    func didBackTapDetected() {
        
        self.dismiss(animated: true, completion: {})
        
    }
    
    func didBlockTapped(sender:UITapGestureRecognizer){
        let friend = sections[(sender.view?.tag)!]
        blockUnfriend(completed: {}, frnd: friend, isBlock: true, tag: (sender.view?.tag)!)
    }
    
    func didUnfriendTapped(sender:UITapGestureRecognizer){
        let friend = sections[(sender.view?.tag)!]
        blockUnfriend(completed: {}, frnd: friend, isBlock: false, tag: (sender.view?.tag)!)
    }
    
    func didTrackTapped(sender:UITapGestureRecognizer){
        
        if(Reachability.isConnectedToNetwork()){
        
        let friend = sections[(sender.view?.tag)!]
        
        if(friend.isTrackingAllowed == true){
            let pref = UserDefaults.standard
            pref.set(friend.friendsUserId, forKey: "FriendSID")
            pref.set("", forKey: "Interest")
            pref.synchronize()
            self.performSegue(withIdentifier: "trackfriend", sender: nil)
            
        }
        else{
            
           
            let msg = "Send Trck Request"
            
            let addTrack = UIAlertController(title: "Track Request", message: msg, preferredStyle: .alert )
            let okAction = UIAlertAction(title: "Allow", style: .default){
                UIAlertAction in
                
                
                
            }
            
            addTrack.addAction(okAction)
            //addTrack.addAction(cancleAction)
            present(addTrack, animated: true, completion: {  })
        }
      }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

      
    }
    
    
    func didAcceptTapped(sender:UITapGestureRecognizer){
        
        if(Reachability.isConnectedToNetwork()){
        let friend = sections[(sender.view?.tag)!]
        sendAcceptFriendRequest(completed: {}, frnd: friend, isaccept: true, tag: (sender.view?.tag)!)
        }else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

        
    }
    
    func didRejectTapped(sender:UITapGestureRecognizer){
        
        if(Reachability.isConnectedToNetwork()){
        let friend = sections[(sender.view?.tag)!]
        sendAcceptFriendRequest(completed: {}, frnd: friend, isaccept: false, tag: (sender.view?.tag)!)
        }else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

        
    }



    
    func switchTriggered(sender: AnyObject) {
        let emergency = sender as! UISwitch
        let utils = Utils()
        let friend = sections[emergency.tag]
        
        if(Reachability.isConnectedToNetwork()){
        if(emergency.isOn == true){
            emergency.thumbTintColor = utils.hexStringToUIColor(hex: "ffffff")
            setAsEmergency(completed: {}, frnd: friend, isemergency: true, tag: emergency.tag)
        }
        else{
            emergency.thumbTintColor = utils.hexStringToUIColor(hex: "7D898B")
            setAsEmergency(completed: {}, frnd: friend, isemergency: false, tag: emergency.tag)
         }
        }else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

       
    }
    
    //Table Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        //return sections[section].items.count
    }
    
    
    //CELL
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell=tableView.dequeueReusableCell(withIdentifier: "FriendlistCell", for:indexPath) as? FriendlistCell
            
        {
            let utils = Utils()
            let friend:FriendListModel = sections[indexPath.section]
            cell.updateCell(user: friend)
            
            cell.selectionStyle = .none
            
            cell.isHighlighted = false
            cell.trackImg.tag = indexPath.section
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(FriendListVC.didTrackTapped(sender:)))
            singleTap.numberOfTapsRequired = 1 // you can change this value
            cell.trackImg.isUserInteractionEnabled = true
            cell.trackImg.addGestureRecognizer(singleTap)
        
            cell.emergencySwitch.tag = indexPath.section
            cell.emergencySwitch.addTarget(self, action: #selector(FriendListVC.switchTriggered(sender:)), for: .valueChanged );
            cell.emergencySwitch.thumbTintColor = utils.hexStringToUIColor(hex: "ffffff")
            
            
            cell.blockImg.tag = indexPath.section
            let singleTapB = UITapGestureRecognizer(target: self, action: #selector(FriendListVC.didBlockTapped(sender:)))
            singleTapB.numberOfTapsRequired = 1 // you can change this value
            cell.blockImg.isUserInteractionEnabled = true
            cell.blockImg.addGestureRecognizer(singleTapB)
            
            cell.unFriendImg.tag = indexPath.section
            let singleTapU = UITapGestureRecognizer(target: self, action: #selector(FriendListVC.didUnfriendTapped(sender:)))
            singleTapU.numberOfTapsRequired = 1 // you can change this value
            cell.unFriendImg.isUserInteractionEnabled = true
            cell.unFriendImg.addGestureRecognizer(singleTapU)

            
            if(friend.status == "Blocked"){
                cell.unFriendImg.isUserInteractionEnabled = false
                cell.blockImg.isUserInteractionEnabled = false
            }
           
            
            cell.backgroundColor = UIColor.clear
            
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: 8.0, height: 7.0)
            cell.layer.shadowRadius = 6.0
            cell.layer.shadowColor = UIColor.black.cgColor

            
            return cell
            
        }
        else{
            
            
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].collapsed ? 0 : 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CollapsibleTableViewHeader") as? CollapsibleTableViewHeader
        
        header?.accept.tag = section
        header?.arrowLabel.tag = section
      /*  if(isSentRequest == true){
          header = setHeaderFRSent(header: header!, section: section)
        }
        else{
            header = setHeaderFRRecieved(header: header!, section: section)

        }*/
        header = setHeaderFRRecieved(header: header!, section: section)
        
        let v = sections[section].friendName
        let stArr = v?.components(separatedBy: " ")
        var st=""
        for s in stArr!{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        let imgText = ImageToText()
        header?.friendImg.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        
        if(sections[section].friendThumbnailUrl != nil){
            if(sections[section].friendThumbnailUrl != ""){
                let downloadImg = DownloadImage()
                downloadImg.setImage(imageurlString: sections[section].friendThumbnailUrl!, imageView: header!.friendImg)
            }
        }

        
        return header
    }
    
func setHeaderFRRecieved(header:CollapsibleTableViewHeader,section:Int) -> CollapsibleTableViewHeader {
    
        let utils = Utils()
    header.friendImg.layer.cornerRadius = 25
    header.friendImg.clipsToBounds = true
    header.titleLabel.text = sections[section].friendName
    header.accept.isHidden = true
    
    header.arrowLabel.layer.borderWidth = 0
  
    
    if(sections[section].status == "Pending"){
        if(sections[section].isRequestSent == false){
        header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "DD2518")
        header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
        header.arrowLabel.text = String.fontAwesomeIcon(name: .close)
        
        header.accept.textColor = utils.hexStringToUIColor(hex: "5CDD67")
        header.accept.font = UIFont.fontAwesome(ofSize: 25)
        header.accept.text = String.fontAwesomeIcon(name: .check)
        header.accept.isHidden = false
        header.accept.layer.borderWidth = 2
        header.accept.layer.borderColor = utils.hexStringToUIColor(hex: "5CDD67").cgColor
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(FriendListVC.didAcceptTapped(sender:)))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        header.accept.isUserInteractionEnabled = true
        header.accept.addGestureRecognizer(singleTap)
        
        let singleTap1 = UITapGestureRecognizer(target: self, action: #selector(FriendListVC.didRejectTapped(sender:)))
        singleTap1.numberOfTapsRequired = 1 // you can change this value
        header.arrowLabel.isUserInteractionEnabled = true
        header.arrowLabel.addGestureRecognizer(singleTap1)
        header.arrowLabel.layer.borderWidth = 2
        header.arrowLabel.layer.borderColor = utils.hexStringToUIColor(hex: "DD2518").cgColor
        }
        else{
            header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "7D898B")
            header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
            header.arrowLabel.text = String.fontAwesomeIcon(name: .hourglass1)
            

        }
        
    }
    else if(sections[section].status == "Rejected"){
        header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "DD2518")
        header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
        header.arrowLabel.text = String.fontAwesomeIcon(name: .userTimes)
        
    }
    else if(sections[section].status == "Blocked"){
        header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "DD2518")
        header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
        header.arrowLabel.text = String.fontAwesomeIcon(name: .timesCircle)
        
    }
    else{
        header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "5CDD67")
        header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
        header.arrowLabel.text = String.fontAwesomeIcon(name: .chevronRight)
        header.arrowLabel.isUserInteractionEnabled = false
        header.setCollapsed(collapsed: sections[section].collapsed)
    }
    header.section = section
    header.delegate = self
    
    return header
    }
    
func setHeaderFRSent(header:CollapsibleTableViewHeader,section:Int) -> CollapsibleTableViewHeader {
    
    let utils = Utils()
    header.friendImg.layer.cornerRadius = 25
    header.friendImg.clipsToBounds = true
    header.titleLabel.text = sections[section].friendName
    header.accept.isHidden = true
    
   
    
    if(sections[section].status == "Pending"){
        header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "7D898B")
        header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
        header.arrowLabel.text = String.fontAwesomeIcon(name: .hourglass1)
        
        
    }
    else if(sections[section].status == "Rejected"){
        header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "DD2518")
        header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
        header.arrowLabel.text = String.fontAwesomeIcon(name: .userTimes)
        
    }
    else if(sections[section].status == "Blocked"){
        header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "DD2518")
        header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
        header.arrowLabel.text = String.fontAwesomeIcon(name: .timesCircle)
        
    }
    else{
        header.arrowLabel.textColor = utils.hexStringToUIColor(hex: "5CDD67")
        header.arrowLabel.font = UIFont.fontAwesome(ofSize: 25)
        header.arrowLabel.text = String.fontAwesomeIcon(name: .chevronRight)
        //header.isUserInteractionEnabled = true
        header.setCollapsed(collapsed: sections[section].collapsed)
    }
    header.section = section
    header.delegate = self
    
    return header
    
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    
    func getFriendList(completed: DownloadComplete){
        self.view.isUserInteractionEnabled = false
        
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
                
                if((res?.count)! > 0){
                    
                 /*   for i in 0...((res?.count)!-1){
                        
                    if((res![i].isRequestSent) == true){
                            self.sentList.append(res![i])
                        }
                    else{
                        self.recievedList.append(res![i])
                        }
                    }*/
                    self.recievedList = res!
                    self.sections = self.recievedList
                    self.friendListTable.delegate = self
                    self.friendListTable.dataSource = self
                    self.friendListTable.reloadData()
                    self.friendListTable.isHidden = false
                    
                }
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Friend List", message: "Failed to fetch friends, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }
    
    func sendAcceptFriendRequest(completed: DownloadComplete, frnd:FriendListModel, isaccept:Bool, tag:Int){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "AcceptRejectFriendRequest"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
               let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        var frienid = frnd.friendsId!
        if(userId == frienid)
        {
            frienid = frnd.userId!
        }
        
        let parameters1 = ["userId":userId,"friendId":frienid,"isEmergencyContact":false,"isAccept":isaccept] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
            
            let respo = response.response?.statusCode
            
            if(respo == 200)
            {
                    if(isaccept == true){
                        self.sections[tag].status = "Accepted"
                    }
                    else{
                        self.sections[tag].status = "Rejected"
                    }
                self.friendListTable.delegate = self
                self.friendListTable.dataSource = self
                self.friendListTable.reloadData()
                
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
                    let msgSend = UIAlertController(title: "Friend Request", message: "Friend Request failed", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true, completion: {  })
                
            }
            
        }
        
        completed()
    }
    
    func sendTrackRequest(completed: DownloadComplete, frnd:FriendListModel, isaccept:Bool, tag:Int){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "SendTrackingRequest"
        Current_Url = "\(TRACK_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        var frienid = frnd.friendsId!
        if(userId == frienid)
        {
            frienid = frnd.userId!
        }
        
        let parameters1 = ["userId":userId,"friendId":frienid,"isAccept":isaccept] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
            
            let respo = response.response?.statusCode
            
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if(respo == 200)
            {
                
                let msgSend = UIAlertController(title: "Friend Request", message: "Track Request Sent Succesfully", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
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

    
    func setAsEmergency(completed: DownloadComplete, frnd:FriendListModel, isemergency:Bool, tag:Int){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "SetFrinedAsEmergencyContact"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        var frienid = frnd.friendsId!
        
        if(userId == frienid)
        {
            frienid = frnd.userId!
        }
        
        let parameters1 = ["userId":userId,"friendId":frienid,"isEmergencyContact":isemergency] as [String : Any]
        
        
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
            
            let respo = response.response?.statusCode
            
            if(respo == 200)
            {
                self.sections[tag].isEmergencyAlert = isemergency
                
                self.friendListTable.delegate = self
                self.friendListTable.dataSource = self
                self.friendListTable.reloadData()
                
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
                    let msgSend = UIAlertController(title: "Emergency Contact", message: "Set as Emergency Contact successfully", preferredStyle: .alert )
                    
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                
                    msgSend.addAction(cancleAction)
                    self.present(msgSend, animated: true, completion: {  })
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
                    let msgSend = UIAlertController(title: "Emergency Contact", message: "Failed to set as Emeregency contact", preferredStyle: .alert )
                    
                    let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    msgSend.addAction(cancleAction)
                    self.present(msgSend, animated: true, completion: {  })
                
            }
            
        }
        
        completed()
    }
    
    
    func blockUnfriend(completed: DownloadComplete, frnd:FriendListModel, isBlock:Bool, tag:Int){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        var methodName = "Unfriend"
        if(isBlock == true){
            methodName = "Block"
        }
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        var frienid = frnd.friendsId!
        if(userId == frienid)
        {
            frienid = frnd.userId!
        }
        
        let parameters1 = ["userId":userId,"friendId":frienid] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            let respo = response.response?.statusCode
            
            if(respo == 200)
            {
                if(isBlock == true){
                    self.sections[tag].status = "Blocked"
                }
                else{
                    self.sections.remove(at: tag)
                }
                self.friendListTable.delegate = self
                self.friendListTable.dataSource = self
                self.friendListTable.reloadData()
                
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
                let msgSend = UIAlertController(title: "Friend", message: "Failed to process the request", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true, completion: {  })
                
            }
            
        }
        
        completed()
    }


    

    @IBAction func filterChange(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == 0){
            isSentRequest = false
            
            self.sections = recievedList
            self.friendListTable.delegate = self
            self.friendListTable.dataSource = self
            self.friendListTable.reloadData()
            
              }
        else{
          /*  isSentRequest = true
            
            self.sections = sentList
            self.friendListTable.delegate = self
            self.friendListTable.dataSource = self
            self.friendListTable.reloadData()*/
        }
    }
    
    
}

//
// MARK: - Section Header Delegate
//
extension FriendListVC: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(header: CollapsibleTableViewHeader, section: Int) {

        
        if(sections[section].status == "Accepted"){
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed: collapsed)
            if(collapsed){
            header.divider.isHidden = false
            }
            else{
                header.divider.isHidden = true
            }
        // Adjust the height of the rows inside the section
        friendListTable.beginUpdates()
        for i in 0 ..< 1 {
            friendListTable.reloadRows(at: [NSIndexPath(row: i, section: section) as IndexPath], with: .automatic)
        }
        friendListTable.endUpdates()
        }
       
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
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(FriendListVC.recievedNotification), name: NSNotification.Name(rawValue: "recievednotif"), object: nil)
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


    
}
