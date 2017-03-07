//
//  AddFriendVC.swift
//  MakeMePopular
//
//  Created by sachin shinde on 13/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//
import UIKit
import Alamofire
import ObjectMapper

class AddFriendVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var radio1: UIImageView!
    
    @IBOutlet weak var legendview: UIView!
    @IBOutlet weak var legendAccepted: UIImageView!
    @IBOutlet weak var legendPending: UIImageView!
    @IBOutlet weak var legendAdd: UIImageView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var search: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nameAddressSV: UIStackView!
    @IBOutlet weak var radio2: UIImageView!
    @IBOutlet weak var back: UIImageView!
    var isradio1Chk:Bool!
    
    @IBOutlet weak var nameadrsMainView: UIView!
    var favOption = [InterestListModel]()
    var addFriendlist = [SearchFriendModel]()
    
    @IBOutlet weak var addFriendTable: UITableView!

    @IBOutlet weak var favPickerView: UIPickerView!
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(AddFriendVC.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        setUpView()
        
        favPickerView.delegate = self
        favPickerView.dataSource = self
        favPickerView.isHidden = true
        
        if(Reachability.isConnectedToNetwork()){
            self.showActivityIndicator()
        getUserInterest {}
        }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }
        
        
        self.addFriendTable.delegate = self
        self.addFriendTable.dataSource = self
        addFriendTable.isHidden = true
        
        let utils = Utils()
        
        legendview.layer.cornerRadius = 4
        legendview.clipsToBounds = true
        legendview.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor
        legendview.layer.borderWidth = 2
        
        
            legendPending.image = UIImage.fontAwesomeIcon(name: .hourglass1, textColor: utils.hexStringToUIColor(hex: "7D898B"), size: CGSize(width: 35, height: 35))
        
       
            legendAccepted.image = UIImage.fontAwesomeIcon(name: .checkSquareO, textColor: utils.hexStringToUIColor(hex: "5CDD67"), size: CGSize(width: 35, height: 35))
        
       
            legendAdd.image = UIImage.fontAwesomeIcon(name: .userPlus, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        
        
    }
    
    func setUpView(){
        isradio1Chk = true
        let utils = Utils()
        
        utils.createGradientLayer(view: self.view)
        
        changeCheck(isr1Check: isradio1Chk)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(AddFriendVC.didTapRadio1))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        radio1.isUserInteractionEnabled = true
        radio1.addGestureRecognizer(singleTap)
        
        let singleTap1 = UITapGestureRecognizer(target: self, action: #selector(AddFriendVC.didTapRadio2))
        singleTap1.numberOfTapsRequired = 1 // you can change this value
        radio2.isUserInteractionEnabled = true
        radio2.addGestureRecognizer(singleTap1)
        
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 45))
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(AddFriendVC.didBackTapDetected))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap2)
        
        
        
        search.image = UIImage.fontAwesomeIcon(name: .search, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        let singleTap3 = UITapGestureRecognizer(target: self, action: #selector(AddFriendVC.didSearchTapped))
        singleTap3.numberOfTapsRequired = 1 // you can change this value
        search.isUserInteractionEnabled = true
        search.addGestureRecognizer(singleTap3)
        
        favPickerView.layer.cornerRadius = 7
        favPickerView.clipsToBounds = true
        favPickerView.layer.borderWidth = 2
        favPickerView.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor
        
        nameadrsMainView.layer.cornerRadius = 7
        nameadrsMainView.clipsToBounds = true
        nameadrsMainView.layer.borderWidth = 2
        nameadrsMainView.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor
        
        
        
    }
    
    
    
    
    func didSearchTapped(){
        
        if((nameField.text != "") && (addressField.text != "")){
            
        }
        else{
            var searchName:String = ""
            if(nameField.text != ""){
               searchName = nameField.text!
            }
            var searchCity:String = ""
            if(addressField.text != ""){
                searchCity = addressField.text!
            }
            if(Reachability.isConnectedToNetwork()){
                self.showActivityIndicator()
            SearchFriend(completed: {}, searchname: searchName, searchcity:searchCity , interest: [])
            }else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }

        }
        
    }
    
    func SearchFriend(completed: DownloadComplete, searchname:String,searchcity:String ,interest:[String]){
        self.view.isUserInteractionEnabled = false
     
        let methodName = "SearchFriends"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        let parameters1 = ["userId":userId,"searchText":searchname,"interest":interest, "city":searchcity] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            let respo = response.response?.statusCode
            let result = response.result
            print("\(result.value)")
            if(respo == 200)
            {
                
                let res = Mapper<SearchFriendModel>().mapArray(JSONObject: result.value)
               
                if((res?.count)! > 0){
                    self.addFriendlist = res!
                    self.addFriendTable.delegate = self
                    self.addFriendTable.dataSource = self
                    self.addFriendTable.reloadData()
                    self.addFriendTable.isHidden = false

                }
                else{
                    let credentialerror = UIAlertController(title: "Add Friend", message: "No People Found Matching Your Specified Search Criteria.", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    
                    credentialerror.addAction(cancelAction)
                    self.present(credentialerror, animated: true, completion: {  })
                }
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Add Friend", message: "Search friend failed, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }
    
    func getUserInterest(completed: DownloadComplete){
        self.view.isUserInteractionEnabled = false
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
                
                if((res?.count)! > 0){
                    self.favOption = res!
                    self.favPickerView.delegate = self
                    self.favPickerView.dataSource = self
                    self.favPickerView.reloadAllComponents()
                    
                }
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Add Friend", message: "Failed to fetch Interests, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }

    
    func didBackTapDetected() {
        
        self.dismiss(animated: true, completion: {})
        
    }
    
    func changeCheck(isr1Check:Bool){
        let utils = Utils()
        
        if(isr1Check == true){
        radio1.image = UIImage.fontAwesomeIcon(name: .checkCircleO, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 30, height: 30))
        radio2.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 30, height: 30))
        
        }else{
            radio2.image = UIImage.fontAwesomeIcon(name: .checkCircleO, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 30, height: 30))
            radio1.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 30, height: 30))
            
            nameField.text = ""
            addressField.text = ""
            
            if(Reachability.isConnectedToNetwork()){
               
                self.showActivityIndicator()
                favPickerView.selectRow(0, inComponent: 0, animated: true)
                SearchFriend(completed: {}, searchname: "", searchcity: "", interest: [favOption[0].interestName!])
                
            }
            else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }
        }

    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    func didTapRadio1() {
       
        
        if(isradio1Chk == false){
            isradio1Chk = true
            changeCheck(isr1Check: isradio1Chk)
            favPickerView.isHidden = true
            nameAddressSV.isHidden = false
            nameadrsMainView.isHidden = false
            addFriendTable.isHidden = true
        }
        
    }
    
    func didTapRadio2() {
       
        if(isradio1Chk == true)
        {
            isradio1Chk = false
            changeCheck(isr1Check: isradio1Chk)
            
            favPickerView.isHidden = false
            nameAddressSV.isHidden = true
            nameadrsMainView.isHidden = true
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return favOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        let utils = Utils()
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Avenir", size: 16)
            pickerLabel?.textAlignment = NSTextAlignment.center
            pickerLabel?.textColor = utils.hexStringToUIColor(hex: "ffffff")
            
            
                pickerLabel?.text = favOption[row].interestName
            
        }
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return favOption[row].interestName
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(Reachability.isConnectedToNetwork()){
            self.showActivityIndicator()
        SearchFriend(completed: {}, searchname: "", searchcity: "", interest: [favOption[row].interestName!])
        }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

        //addFriendTable.isHidden = false
        
    }
    
    //Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return addFriendlist.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 7
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell=tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for:indexPath) as? AddFriendCell
            
          {
            
            cell.updateCell(user: addFriendlist[indexPath.section])
            cell.selectionStyle = .none
            cell.isHighlighted = false
            cell.addfriend.tag = indexPath.section
            
            if(addFriendlist[indexPath.section].requestStatus != "Pending" && addFriendlist[indexPath.section].requestStatus != "Accepted"){
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(AddFriendVC.didAddFriendTapped(sender:)))
            singleTap.numberOfTapsRequired = 1 // you can change this value
            cell.addfriend.isUserInteractionEnabled = true
            cell.addfriend.addGestureRecognizer(singleTap)
            }
            
            let utils = Utils()
        //cell.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "shadow"))
            cell.backgroundColor = UIColor.clear
            cell.layer.borderWidth = 1
            cell.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor
            cell.layer.cornerRadius = 5
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
    
    
    func didAddFriendTapped(sender:UITapGestureRecognizer){
        
        let friend = addFriendlist[(sender.view?.tag)!]
        
        sendFriendRequest(completed: {}, frnd: friend,tag: (sender.view?.tag)!)
        
       }
    
    func sendFriendRequest(completed: DownloadComplete, frnd:SearchFriendModel,tag:Int){
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        let methodName = "SendFriendRequest"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        let parameters1 = ["userId":userId,"friendId":frnd.userId!,"isEmergencyContact":false] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
           
            let respo = response.response?.statusCode
           
            if(respo == 200)
            {
                frnd.requestStatus = "Pending"
                self.addFriendlist[tag] = frnd
                
                self.addFriendTable.dataSource = self
                self.addFriendTable.delegate = self
                self.addFriendTable.reloadData()
                
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
               
                let msgSend = UIAlertController(title: "Friend Request", message: "Friend Request sent Successfully", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true, completion: {  })
                
                
                
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
        NotificationCenter.default.addObserver(self, selector:#selector(AddFriendVC.recievedNotification), name: NSNotification.Name(rawValue: "recievednotif"), object: nil)
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
