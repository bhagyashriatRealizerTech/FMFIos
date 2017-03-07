//
//  NearMeFriendVC.swift
//  MakeMePopular
//
//  Created by Mac on 20/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import ObjectMapper

class NearMeFriendVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var distanceSlider: CustomSlider!
    @IBOutlet weak var filter: UIImageView!
    @IBOutlet weak var back: UIImageView!
    @IBOutlet weak var mapview: GMSMapView!
    
    @IBOutlet weak var filterView: UIView!
    
    @IBOutlet weak var close: UIImageView!
    @IBOutlet weak var radio1: UIImageView!
    var locationManager = CLLocationManager()
    @IBOutlet weak var radio2: UIImageView!
    var didFindMyLocation = false
    var isFavOpen:Bool = false
    var nearMeFriendlist = NearByFriendMainResModel()
    
    @IBOutlet weak var pickerView: UIPickerView!
    var mapTasks = MapTask()
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var myLoc:CLLocation!
    var friendID:String = ""
    var distance:Int = 25
    var listCount = 0
    var selectedRow = 0
    var isTrackagain:Bool = false
    var totalCount:Int = 0
    var counter:Int = 0
    
    var isradio1Chk:Bool!
    var favOption = [InterestListModel]()
    var friendList = [FriendListModel]()
    var interests:String = ""
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    var originAddress: String!
    var destinationAddress: String!
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    var routePolyline: GMSPolyline!
    

    @IBOutlet weak var prevButton: UIImageView!
       
    @IBOutlet weak var nextButton: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var pageNo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapview.delegate = self
        self.mapview.isMyLocationEnabled = true
        bottomView.isHidden = true
        
         setUpView()
        pickerView.delegate = self
        pickerView.dataSource = self
        filterView.isHidden = true
        
        
        
        let utils = Utils()
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 45))
                
        myLoc = CLLocation(latitude: UserDefaults.standard.value(forKey: "latitude") as! Double, longitude: UserDefaults.standard.value(forKey: "longitude") as! Double)
        
        friendID = UserDefaults.standard.value(forKey: "FriendSID") as! String
        
        if(friendID == "" || friendID == "All"){
             bottomView.isHidden = false
            mapview.camera = GMSCameraPosition.camera(withTarget: myLoc.coordinate, zoom: 10.0)
            mapview.settings.myLocationButton = false
            setupMylocationMarker(coordinate: myLoc.coordinate)
            didFindMyLocation = true
            
            interests = UserDefaults.standard.value(forKey: "Interest") as! String
            if(interests == ""){
                if(Reachability.isConnectedToNetwork()){
                    counter = 0
                 getNearByFriends(completed: {}, interest: "")
                    
                }
                else {
                    
                    let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    
                    credentialerror.addAction(cancelAction)
                    self.present(credentialerror, animated: true, completion: {  })
                    
                }
            
                
            }
            else{
                if(Reachability.isConnectedToNetwork()){
                    counter = 0
                    getNearByFriends(completed: {}, interest: interests)
                    
                }
                else {
                    
                    let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    
                    credentialerror.addAction(cancelAction)
                    self.present(credentialerror, animated: true, completion: {  })
                    
                }
                
            }
        }
        else{
             bottomView.isHidden = true
            mapview.camera = GMSCameraPosition.camera(withTarget: myLoc.coordinate, zoom: 10.0)
            mapview.settings.myLocationButton = false
            setupMylocationMarker(coordinate: myLoc.coordinate)
            didFindMyLocation = true
            
            if(Reachability.isConnectedToNetwork()){
                isTrackagain = true
                trackfriend(completed: {}, friendID: friendID)
                
            }
            else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }

            
           // var timer = Timer.scheduledTimer(timeInterval:2000, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
        }
        
       distanceSlider.value = 25
        
    }
    
    func setUpView(){
        isradio1Chk = true
        let utils = Utils()
        
        changeCheck(isr1Check: isradio1Chk)
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(NearMeFriendVC.didTapRadio1))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        radio1.isUserInteractionEnabled = true
        radio1.addGestureRecognizer(singleTap2)
        
        let singleTap3 = UITapGestureRecognizer(target: self, action: #selector(NearMeFriendVC.didTapRadio2))
        singleTap3.numberOfTapsRequired = 1 // you can change this value
        radio2.isUserInteractionEnabled = true
        radio2.addGestureRecognizer(singleTap3)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(NearMeFriendVC.didBackTapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap)
        
        filter.image = UIImage.fontAwesomeIcon(name: .filter, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 40))
        let singleTap1 = UITapGestureRecognizer(target: self, action: #selector(NearMeFriendVC.didfilterTapDetected))
        singleTap1.numberOfTapsRequired = 1 // you can change this value
        filter.isUserInteractionEnabled = true
        filter.addGestureRecognizer(singleTap1)
        
        close.image = UIImage.fontAwesomeIcon(name: .close, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 40))
        let singleTap4 = UITapGestureRecognizer(target: self, action: #selector(NearMeFriendVC.didCloseTapDetected))
        singleTap4.numberOfTapsRequired = 1 // you can change this value
        close.isUserInteractionEnabled = true
        close.addGestureRecognizer(singleTap4)
        
        
        prevButton.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 40))
        let singleTap5 = UITapGestureRecognizer(target: self, action: #selector(NearMeFriendVC.didPrevTapView))
        singleTap5.numberOfTapsRequired = 1 // you can change this value
        prevButton.isUserInteractionEnabled = true
        prevButton.addGestureRecognizer(singleTap5)
        
        nextButton.image = UIImage.fontAwesomeIcon(name: .chevronRight, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 40))
        let singleTap6 = UITapGestureRecognizer(target: self, action: #selector(NearMeFriendVC.didNextTapView))
        singleTap6.numberOfTapsRequired = 1 // you can change this value
        nextButton.isUserInteractionEnabled = true
        nextButton.addGestureRecognizer(singleTap6)
        
        
        pickerView.layer.borderWidth = 1
        pickerView.layer.borderColor = utils.hexStringToUIColor(hex: "0097A7").cgColor
        
        search.layer.cornerRadius = 7
        search.layer.shadowOpacity = 0.5
        search.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        search.layer.shadowRadius = 5.0
        search.layer.shadowColor = UIColor.black.cgColor
        
    }
    
    func changeCheck(isr1Check:Bool){
        let utils = Utils()
        
        if(isr1Check == true){
            distanceSlider.isHidden = false
            distanceSlider.label.isHidden = false
             bottomView.isHidden = false
            
            radio1.image = UIImage.fontAwesomeIcon(name: .checkCircleO, textColor: utils.hexStringToUIColor(hex: "0097A7"), size: CGSize(width: 30, height: 30))
            radio2.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "0097A7"), size: CGSize(width: 30, height: 30))
            if(Reachability.isConnectedToNetwork()){
                if(favOption.count == 0){
                  getUserInterest {}
                }
                else{
                    self.pickerView.delegate = self
                    self.pickerView.dataSource = self
                    self.pickerView.reloadAllComponents()
                    self.pickerView.selectRow(0, inComponent: 0, animated: true)
                    
                    if(self.isFavOpen == true){
                        selectedRow = 0
                    }
                   
                }
            }
            else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }

            
        }else{
            
            distanceSlider.isHidden = true
            distanceSlider.label.isHidden = true
             bottomView.isHidden = true
            
            radio2.image = UIImage.fontAwesomeIcon(name: .checkCircleO, textColor: utils.hexStringToUIColor(hex: "0097A7"), size: CGSize(width: 30, height: 30))
            radio1.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "0097A7"), size: CGSize(width: 30, height: 30))
            if(Reachability.isConnectedToNetwork()){
                if(friendList.count == 0){
                   
                     getFriendList {}
                }
                else{
                    self.pickerView.delegate = self
                    self.pickerView.dataSource = self
                    self.pickerView.reloadAllComponents()
                    self.pickerView.selectRow(0, inComponent: 0, animated: true)
                    
                    if(isFavOpen == true){
                        selectedRow = 0
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
        
    }
    
    func setUpPrevNext(){
        
        if(counter > 0){
           prevButton.isHidden = false
        }
        else{
            prevButton.isHidden = true
        }
        
        if((counter + 1) < totalCount){
            nextButton.isHidden = false
        }
        else{
            nextButton.isHidden = true
        }
        
        pageNo.text = "Page "+String(counter + 1)+" of "+String(totalCount)
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    func didPrevTapView(){
      
        counter = counter - 1
        if(Reachability.isConnectedToNetwork()){
            getNearByFriends(completed: {}, interest: interests)
        }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

    }

    
    func didNextTapView(){
        
        counter = counter + 1
        if(Reachability.isConnectedToNetwork()){
            getNearByFriends(completed: {}, interest: interests)
        }
        else {
            
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

    }
    
    func didAddFriendTap(sender:UITapGestureRecognizer){
        let friend = nearMeFriendlist.results?[(sender.view?.tag)!]
        sendFriendRequest(completed: {}, frnd: friend!, tag: (sender.view?.tag)!)
    
    }

    
    func didTapRadio1() {
        
        if(isradio1Chk == false)
        {
            isradio1Chk = true
            changeCheck(isr1Check: isradio1Chk)
        }
        
    }
    
    func didTapRadio2() {
        
        if(isradio1Chk == true)
        {
            isradio1Chk = false
            changeCheck(isr1Check: isradio1Chk)
            
        }
    }

    
    func didBackTapDetected() {
        self.mapview.removeObserver(self, forKeyPath: "myLocation", context: nil)
        self.dismiss(animated: true, completion: {})
        
    }
    
    func didfilterTapDetected() {
        
        filterView.isHidden = false
        isFavOpen = true
        
    }
    func didCloseTapDetected() {
        
        filterView.isHidden = true
        isFavOpen = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.mapview.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(NearMeFriendVC.recievedNotification), name: NSNotification.Name(rawValue: "recievednotif"), object: nil)
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapview.isMyLocationEnabled = true
        }
        
    }
    
    @objc override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            mapview.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
            mapview.settings.myLocationButton = false
            setupMylocationMarker(coordinate: myLocation.coordinate)
            didFindMyLocation = true
            
            myLoc = myLocation
            
        }
        
    }
    
    func setupMylocationMarker(coordinate: CLLocationCoordinate2D) {
        /*let utils = Utils()
        
        locationMarker = GMSMarker(position: coordinate)
        let view1:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 93))
        let uiImageView:UIImageView  = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let info1:UITextView = UITextView(frame: CGRect(x: 10, y: 63, width: 40, height: 30))
        
        
        
        info1.backgroundColor = utils.hexStringToUIColor(hex: "00BCD4")
        info1.textColor = utils.hexStringToUIColor(hex: "ffffff")
        info1.layer.cornerRadius = 5
        info1.clipsToBounds = true
        info1.font = UIFont(name: "Avenir", size: 15)
        info1.text = "Me"
        
        uiImageView.layer.cornerRadius = 31
        uiImageView.clipsToBounds = true
        
        let fname:String = UserDefaults.standard.value(forKey: "UserFName") as! String
        let lname:String = UserDefaults.standard.value(forKey: "UserLName") as! String
        let thumbnailurl = UserDefaults.standard.value(forKey: "ProfilePic") as! String
        let v = fname + " " + lname
        let stArr = v.components(separatedBy: " ")
        var st=""
        for s in stArr{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        let imgText = ImageToText()
        uiImageView.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        
        if(thumbnailurl != ""){
            let downloadImg = DownloadImage()
            downloadImg.setImage(imageurlString: thumbnailurl, imageView: uiImageView)
        }
        
        
        
        view1.addSubview(uiImageView)
        view1.addSubview(info1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 150, height: 93), false, 0)
        
        view1.drawHierarchy(in: CGRect(x: 0, y: 0, width: view1.bounds.size.width, height: view1.bounds.size.height), afterScreenUpdates: true)
        let markerimg:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        locationMarker.icon = markerimg
        locationMarker.map = mapview*/
        

        
    }
    
    func setuplocationMarker(coordinate: CLLocationCoordinate2D, info: String, userName:String,thumbnailUrl:String, tag:Int) {
        let utils = Utils()
        
        locationMarker = GMSMarker(position: coordinate)
        let view1:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 225, height: 105))
        let uiImageView:UIImageView  = UIImageView(frame: CGRect(x: 2, y: 3, width: 60, height: 60))
        let info1:UITextView = UITextView(frame: CGRect(x: 65, y: 0, width: 225, height: 65))
        let add:UIButton = UIButton(frame: CGRect(x: 65, y: 70, width: 80, height: 25))
       
        info1.contentOffset = CGPoint(x: 0, y: 0)
                
        view1.backgroundColor = utils.hexStringToUIColor(hex: "00BCD4")
        view1.layer.cornerRadius = 5
        view1.clipsToBounds = true
        
        info1.backgroundColor = UIColor.clear
        info1.textColor = utils.hexStringToUIColor(hex: "ffffff")
        info1.font = UIFont(name: "Avenir", size: 15)
        info1.text = info
        
        uiImageView.layer.cornerRadius = 31
        uiImageView.clipsToBounds = true
        
        let v = userName
        let stArr = v.components(separatedBy: " ")
        var st=""
        for s in stArr{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        let imgText = ImageToText()
        uiImageView.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        
        
            if(thumbnailUrl != ""){
                let downloadImg = DownloadImage()
                downloadImg.setImage(imageurlString: thumbnailUrl, imageView: uiImageView)
            }

        
        add.backgroundColor = utils.hexStringToUIColor(hex: "008080")
        add.layer.cornerRadius = 2
        add.layer.shadowOpacity = 0.5
        add.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        add.layer.shadowRadius = 5.0
        add.layer.shadowColor = UIColor.black.cgColor
        add.setTitleColor(UIColor.white, for: .normal)
        add.setTitle("Add", for: .normal)
        add.tag = tag
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(NearMeFriendVC.didAddFriendTap(sender:)))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        add.isUserInteractionEnabled = true
        add.addGestureRecognizer(singleTap)
        
        
        view1.addSubview(uiImageView)
        view1.addSubview(info1)
        view1.addSubview(add)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 225, height: 105), false, 0)
        
        view1.drawHierarchy(in: CGRect(x: 0, y: 0, width: view1.bounds.size.width, height: view1.bounds.size.height), afterScreenUpdates: true)
        let markerimg:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        locationMarker.icon = markerimg
        locationMarker.map = mapview
        print("\(thumbnailUrl)")
    }
    
    func setuplocationMarkerFriend(coordinate: CLLocationCoordinate2D, info: String, userName:String,thumbnailUrl:String) {
        let utils = Utils()
        
        locationMarker = GMSMarker(position: coordinate)
        let view1:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 213, height: 75))
        let uiImageView:UIImageView  = UIImageView(frame: CGRect(x: 3, y: 8, width: 60, height: 60))
        let info1:UITextView = UITextView(frame: CGRect(x: 66, y: 0, width: 150, height: 75))
        
        
        info1.contentOffset = CGPoint(x: 0, y: 0)
        
        view1.backgroundColor = utils.hexStringToUIColor(hex: "00BCD4")
        view1.layer.cornerRadius = 5
        view1.clipsToBounds = true
        
        info1.backgroundColor = UIColor.clear
        info1.textColor = utils.hexStringToUIColor(hex: "ffffff")
        info1.font = UIFont(name: "Avenir", size: 15)
        info1.text = info
        
        uiImageView.layer.cornerRadius = 31
        uiImageView.clipsToBounds = true
        
        let v = userName
        let stArr = v.components(separatedBy: " ")
        var st=""
        for s in stArr{
            if let      str=s.characters.first{
                st+=String(str).capitalized
            }
        }
        
        
        
        let imgText = ImageToText()
        uiImageView.image = imgText.textToImage(drawText: st as NSString, inImage: #imageLiteral(resourceName: "greybg"), atPoint: CGPoint(x: 20.0, y: 20.0))
        
        if(thumbnailUrl != ""){
            let downloadImg = DownloadImage()
            downloadImg.setImage(imageurlString: thumbnailUrl, imageView: uiImageView)
        }

        
        
        view1.addSubview(uiImageView)
        view1.addSubview(info1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 213, height: 75), false, 0)
        
        view1.drawHierarchy(in: CGRect(x: 0, y: 0, width: view1.bounds.size.width, height: view1.bounds.size.height), afterScreenUpdates: true)
        let markerimg:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        locationMarker.icon = markerimg
        locationMarker.map = mapview
        
    }

    
    
    func getNearByFriends(completed: DownloadComplete,interest:String){
        
        
        self.filterView.isHidden = true
        self.isFavOpen = false
        
         //self.view.isUserInteractionEnabled = true
         self.view.isUserInteractionEnabled = false
        // self.hideActivityIndicator()
         self.showActivityIndicator()
      
        let methodName = "GetNearByfriend"
        Current_Url = "\(TRACK_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        let latitude:Double = myLoc.coordinate.latitude as Double
        let longitude:Double = myLoc.coordinate.longitude as Double
        distance = UserDefaults.standard.integer(forKey: "Distance") * 1000
        
        let ipbody = ["userId":userId, "latitude":latitude, "longitude":
            longitude, "intrest":interest, "distanceBetween":distance, "page":counter] as [String : Any]
        
       
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        print("\(ipbody)")
        print("\(longitude)")
        
        Alamofire.request(current_url, method: .post, parameters: ipbody, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            let resStatus = response.response?.statusCode
            let apiResult = response.result
             print("\(resStatus)")
            if(resStatus == 200)
            {
                
               let mapRes = Mapper<NearByFriendMainResModel>().map(JSONObject: apiResult.value)
                self.nearMeFriendlist = mapRes!
                print("\(apiResult.value)")
                
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
               
                self.mapview.clear()
                
                if(mapRes?.totalPages != nil){
                self.totalCount = (mapRes?.totalPages!)!
                }
                
                self.setUpPrevNext()
                
                
                if((mapRes?.results?.count)! > 0){
                    for i in 0 ... ((mapRes?.results?.count)! - 1){
                        
                        let lat:Double = mapRes!.results![i].latitude!
                        let longi:Double = mapRes!.results![i].longitude!
                        
                        let friendLoc = CLLocation(latitude: lat,longitude: longi)
                        let name:String = (mapRes?.results?[i].friendName!)!
                        let gender:String = (mapRes?.results?[i].gender!)!
                        let ageIn:Int = (mapRes?.results?[i].age!)! as Int
                        let age:String = String(describing: ageIn)
                        let thumburl:String = (mapRes?.results?[i].thumbnailUrl!)!
                        
                        var information:String = name + "\n" + gender + ", " + age
                        let lastupdate:String = self.getLocalDate(utcDate: (mapRes?.results?[i].lastUpdatedOn)!)
                        
                        information = name + "\n" + gender + " , " + age + "\n" + lastupdate
                        
                        self.setuplocationMarkerFriend(coordinate: friendLoc.coordinate, info: information, userName: name, thumbnailUrl: thumburl)
                        
                        /*if(interest == ""){
                            self.setuplocationMarkerFriend(coordinate: friendLoc.coordinate, info: information, userName: name, thumbnailUrl: thumburl)
                        }
                        else{
                            
                            self.setuplocationMarker(coordinate: friendLoc.coordinate, info: information, userName: name, thumbnailUrl: thumburl, tag: i)
                        }*/
                        
                    }
                }
                else{
                    self.view.isUserInteractionEnabled = true
                    self.hideActivityIndicator()
                    
                    let credentialerror = UIAlertController(title: "Near Me Friends", message: "No people matching your interests found in the provided range. Please change the criteria or increase the range.", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    
                    credentialerror.addAction(cancelAction)
                    self.present(credentialerror, animated: true, completion: {  })
 
                }
                self.setupMylocationMarker(coordinate: self.myLoc.coordinate)
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Near Me Friend", message: "Failed to Track Friend, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }
    
    func trackfriend(completed: DownloadComplete,friendID:String){
        
        filterView.isHidden = true
        isFavOpen = false
        
        self.view.isUserInteractionEnabled = false
        //self.hideActivityIndicator()
        self.showActivityIndicatorTrackFriend()
        
        let methodName = "TrackFriend"
        Current_Url = "\(TRACK_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        let parameters1 = ["userId":userId,"friendId":friendID, "isNotify":true] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json","Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            
            let respo = response.response?.statusCode
            let result = response.result
            print("\(respo)")
            if(respo == 200)
            {
                print("\(result.value)")
                
                if let dict = result.value as? [String: AnyObject]
                {
                    let res = Mapper<TrackFriendModel>().map(JSONObject: dict)
                    
                    let lat:Double = (res?.latitude)!
                    let longi:Double = (res?.longitude)!
                    
                    let friendLoc = CLLocation(latitude: lat,longitude: longi)
                    
                    
                    self.hideActivityIndicator()
                    self.view.isUserInteractionEnabled = true
                    
                    self.mapview.clear()
                    self.setupMylocationMarker(coordinate: self.myLoc.coordinate)
                    
                    let name:String = (res?.friendName!)!
                    let gender:String = (res?.gender!)!
                    let thumburl:String = (res?.thumbnailUrl!)!
                    let ageIn:Int = (res?.age)! as Int
                    let age:String = String(describing: ageIn)
                    
                    let lastupdate:String = self.getLocalDate(utcDate: (res?.lastUpdatedOn)!)
                    
                    let information:String = name + "\n" + gender + " , " + age + "\n" + lastupdate
                    
                    
                    /* if(UserDefaults.standard.value(forKey: "Route") == nil){
                    self.setuplocationMarkerFriend(coordinate: friendLoc.coordinate,info: information,userName: name,thumbnailUrl: thumburl)
                    }
                    else if(UserDefaults.standard.value(forKey: "Route") as! Bool == false){
                        self.setuplocationMarkerFriend(coordinate: friendLoc.coordinate,info: information,userName: name,thumbnailUrl: thumburl)
                    }
                    else if(UserDefaults.standard.value(forKey: "Route") as! Bool == true){
                        
                        UserDefaults.standard.set(false, forKey: "Route")
                        UserDefaults.standard.synchronize()
                        
                        self.showRoute(completed: {}, frndLatLan: friendLoc.coordinate, information: information, name: name, pic: thumburl)
                    }*/
                    
                    let utils = Utils()
                    let lastTime = lastupdate.components(separatedBy: " ")[1].components(separatedBy: ":")
                    let timestamp = utils.getCurrentDate().components(separatedBy: " ")
                    let currentTime = timestamp[1].components(separatedBy: ":")
                    let hrDiff = Int(currentTime[0])! - Int(lastTime[0])!
                    let miDiff = Int(currentTime[1])! - Int(lastTime[1])!
                    
                    if(hrDiff == 0 && miDiff <= 1 && lastupdate.components(separatedBy: " ")[2] == timestamp[2]){
                        self.isTrackagain = false
                    }
                    else{
                    if(self.isTrackagain == true){
                        self.isTrackagain = false
                        let credentialerror = UIAlertController(title: "Track Friend", message: "Your friend was located at "+lastupdate+".Do you want to show that location???", preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "Ok", style: .default){ UIAlertAction in
                            if(Reachability.isConnectedToNetwork()){
                                
                                self.trackfriend(completed: {}, friendID: friendID)
                                credentialerror.dismiss(animated: true, completion: nil)
                            }
                            else {
                                
                            }
                        }
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ UIAlertAction in
                             self.showRoute(completed: {}, frndLatLan: friendLoc.coordinate, information: information, name: name, pic: thumburl)
                            credentialerror.dismiss(animated: true, completion: nil)
                        }
                        
                        credentialerror.addAction(okAction)
                        credentialerror.addAction(cancelAction)
                        self.present(credentialerror, animated: true, completion: {  })
                    }
                  }
                }

                
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                 self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Near Me Friend", message: "Failed to Track Friend, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }
    
    
    func getUserInterest(completed: DownloadComplete){
        
        //self.view.isUserInteractionEnabled = false
        //self.showActivityIndicator()
        
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
                    self.pickerView.isHidden = false
                    self.favOption = res!
                    self.pickerView.delegate = self
                    self.pickerView.dataSource = self
                    self.pickerView.reloadAllComponents()
                    if(self.isFavOpen == true){
                    self.selectedRow = 0
                    }
                }
                else{
                    self.pickerView.isHidden = true
                }
               // self.hideActivityIndicator()
               // self.view.isUserInteractionEnabled = true
                
            }
            else{
                self.pickerView.isHidden = true
                //self.view.isUserInteractionEnabled = true
                //self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Near Me Friend", message: "Failed to fetch user interest, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }
    
    
    func getFriendList(completed: DownloadComplete){
        
        //self.view.isUserInteractionEnabled = false
        //self.showActivityIndicator()
        
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
                   
                    
                    for i in 0...((res?.count)! - 1)
                    {
                        if(res?[i].status == "Accepted")
                        {
                            self.friendList.append((res?[i])!)
                        }
                    }
                    
                    if(self.friendList.count > 0){
                        let frnd = FriendListModel()
                        frnd.setupValue(friendName1: "All")
                        self.friendList.append(frnd)
                        
                    }
                    self.pickerView.isHidden = false
                    self.pickerView.delegate = self
                    self.pickerView.dataSource = self
                    self.pickerView.reloadAllComponents()
                    
                    if(self.isFavOpen == true){
                         if(self.friendList.count > 0){
                          self.selectedRow = 0
                        }
                    }
                    
                }
                else{
                    self.pickerView.isHidden = true
                }
                
                //self.view.isUserInteractionEnabled = true
                //self.hideActivityIndicator()
                
            }else{
                //self.pickerView.isHidden = true
               // self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Near Me Friend", message: "Failed to fetch Friends, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }
    func sendFriendRequest(completed: DownloadComplete, frnd:NearByFriendResponseModel,tag:Int){
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        let methodName = "SendFriendRequest"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        let parameters1 = ["userId":userId,"friendId":frnd.friendUserId!,"isEmergencyContact":false] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
            
            let respo = response.response?.statusCode
            
            if(respo == 200)
            {
                self.nearMeFriendlist.results?.remove(at: tag)
                let mapRes = self.nearMeFriendlist
                
                
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
                self.mapview.clear()

                
                for i in 0...((mapRes.results?.count)! - 1 ){
                let lat:Double = mapRes.results![i].latitude!
                let longi:Double = mapRes.results![i].longitude!
                
                let friendLoc = CLLocation(latitude: lat,longitude: longi)
                let name:String = (mapRes.results?[i].friendName!)!
                let gender:String = (mapRes.results?[i].gender!)!
                let ageIn:Int = (mapRes.results?[i].age!)! as Int
                let age:String = String(describing: ageIn)
                let thumburl:String = (mapRes.results?[i].thumbnailUrl!)!
                
                var information:String = name + "\n" + gender + ", " + age
                let lastupdate:String = self.getLocalDate(utcDate: (mapRes.results?[i].lastUpdatedOn)!)
                
                information = name + "\n" + gender + " , " + age + "\n" + lastupdate
                
                
                    self.setuplocationMarker(coordinate: friendLoc.coordinate, info: information, userName: name, thumbnailUrl: thumburl, tag: i)
                
                }
                
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
    
    func getLocalDate(utcDate:String) -> String{
        let tempDate:String = utcDate.components(separatedBy: ".")[0]
        var localDate:String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let date = dateFormatter.date(from: tempDate)// create   date from string
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "dd/MM/yyyy h:mm a"
        dateFormatter.timeZone = TimeZone.current
        localDate = dateFormatter.string(from: date!)
        return localDate
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(isradio1Chk == true)
        {
        return favOption.count
        }
        else{
            return friendList.count
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
            
            if(isradio1Chk == true){
                pickerLabel?.text = favOption[row].interestName
            }
            else{
                pickerLabel?.text = friendList[row].friendName
            }
        }
        
        return pickerLabel!;
    }

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(isradio1Chk == true)
        {
        return favOption[row].interestName
        }
        else{
            return friendList[row].friendName
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedRow = row
        
    }
    
    func showOnMap(row:Int){
        if(isradio1Chk == true){
            if(Reachability.isConnectedToNetwork()){
                counter = 0
                interests = favOption[row].interestName!
                
                getNearByFriends(completed: {}, interest: favOption[row].interestName!)
            }
            else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }
        }
        else{
            if(Reachability.isConnectedToNetwork()){
                if(friendList[row].friendsUserId == nil){
                    counter = 0
                    interests = ""
                    bottomView.isHidden = false
                    getNearByFriends(completed: {}, interest: interests)
                }
                else{
                isTrackagain = true
                trackfriend(completed: {}, friendID: friendList[row].friendsUserId!)
                }
            }
            else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }
        }
    }
    
    
    func showActivityIndicatorTrackFriend() {
        
        // UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DispatchQueue.main.async {
            let utils = Utils()
            
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 80.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = utils.hexStringToUIColor(hex: "ffffff")
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10
            
            let info1:UITextView = UITextView(frame: CGRect(x: 65, y: 2.5, width: 135.0, height: 75))
            info1.backgroundColor = UIColor.clear
            info1.textColor = utils.hexStringToUIColor(hex: "32A7B6")
            info1.font = UIFont(name: "Avenir", size: 12)
            info1.text = "Tracking Current Location of your friend, please wait.."

            
            let actInd = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            actInd.color = utils.hexStringToUIColor(hex: "32A7B6")
            self.spinner = actInd
            self.spinner.frame = CGRect(x: 0.0, y: 10.0, width: 60.0, height: 60.0)
            //self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)
            
            self.loadingView.addSubview(self.spinner)
            self.loadingView.addSubview(info1)
            self.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
            
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
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 70.0, height: 70.0)
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
    
    @IBAction func searchClick(_ sender: Any) {
      
        distance = Int(distanceSlider.value)
        UserDefaults.standard.set(distance, forKey: "Distance")
        UserDefaults.standard.synchronize()

        
        if(self.isradio1Chk == true){
          if(self.favOption.count > 0){
          showOnMap(row: selectedRow)
          }
          else{
            let msgSend = UIAlertController(title: "Near Me", message: "No  interests available to proceed", preferredStyle: .alert )
            
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            msgSend.addAction(cancleAction)
            self.present(msgSend, animated: true, completion: {  })
            }
        }
        else{
            if(self.friendList.count > 0){
                showOnMap(row: selectedRow)
            }
            else{
                let msgSend = UIAlertController(title: "Near Me", message: "No  friend available to proceed", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true, completion: {  })
            }
        }
    }
    
    func showRoute(completed: DownloadComplete,frndLatLan: CLLocationCoordinate2D, information:String, name:String, pic:String){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        
        originAddress = String(myLoc.coordinate.latitude) + "," + String(myLoc.coordinate.longitude)
        destinationAddress = String(frndLatLan.latitude) + "," + String(frndLatLan.longitude)
        
        let origin = "origin=" + self.originAddress
        let destination = "&destination=" + self.destinationAddress
       // let apiKey = "&key=AIzaSyBUThKY77ySu0loIItwOPRWjwNk6pU4L_I"
        let mode = "&mode=driving"
        
        Current_Url = "\(ROUTE_URL)\(origin)\(destination)\(mode)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        print(current_url)
        
        Alamofire.request(current_url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON{ response in
            
            let respo = response.response?.statusCode
            let result = response.result
            
            if(respo == 200)
            {
                
                if let dictionary = result.value as? [String: AnyObject]
                {
                    // Get the response status.
                    let status1:String = dictionary["status"] as! String
                    
                    if status1 == "OK" {

                        self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                        self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                        
                        self.setupMylocationMarker(coordinate: self.myLoc.coordinate)
                        
                        self.setuplocationMarkerFriend(coordinate: frndLatLan, info: information, userName: name, thumbnailUrl: pic)
                        
                        self.view.isUserInteractionEnabled = true
                        self.hideActivityIndicator()
                        
                        self.drawRoute()
                        
                    }
                    else {
                        self.view.isUserInteractionEnabled = true
                        self.hideActivityIndicator()
                        print(status1)
                    }
                }
                
                
            }
            else{
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            }
            
        }
        
        completed()
    }
    
    func drawRoute() {
        let route = self.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = self.mapview
    }
    

}


