//
//  NearMePlaces.swift
//  MakeMePopular
//
//  Created by Mac on 01/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//
import UIKit
import GoogleMaps

import Alamofire

class NearMePlaces: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var healthimg: UILabel!
    @IBOutlet weak var templeimg: UILabel!
    @IBOutlet weak var atmimg: UILabel!
    @IBOutlet weak var movieimg: UILabel!
    @IBOutlet weak var shopimg: UILabel!
    @IBOutlet weak var drinkimg: UILabel!
    @IBOutlet weak var foodimg: UILabel!
    @IBOutlet weak var pumpimg: UILabel!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filter: UIImageView!
    @IBOutlet weak var back: UIImageView!
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker: GMSMarker!
    var myLoc:CLLocation!
    var lookupAddressResults: Dictionary<String, AnyObject>!
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    var isFilterOpen:Bool = false
    
    var searchType:String = ""
    var rad:String = ""
    let nearbyPlaces = "https://maps.googleapis.com/maps/api/place/search/json?"
    var SearchList = [NearByPlacesModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        
        if(UserDefaults.standard.value(forKey: "latitude") != nil && UserDefaults.standard.value(forKey: "longitude") != nil){
        myLoc = CLLocation(latitude: UserDefaults.standard.value(forKey: "latitude") as! Double, longitude: UserDefaults.standard.value(forKey: "longitude") as! Double)
        }
        SetUpMap()
        
        setupView()
                
    }
    
    func SetUpMap(){
    
        mapView.camera = GMSCameraPosition.camera(withTarget: myLoc.coordinate, zoom: 10.0)
        mapView.settings.myLocationButton = false
        didFindMyLocation = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(NearMePlaces.recievedNotification), name: NSNotification.Name(rawValue: "recievednotif"), object: nil)
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
        }
        
    }
    
    @objc override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = false
            didFindMyLocation = true
            
            myLoc = myLocation
            
        }
        
    }
    
    func setupView(){
        
        filterView.isHidden = true
        
        let utils = Utils()
       
        pumpimg.layer.cornerRadius = 25
        pumpimg.clipsToBounds = true
        pumpimg.textColor = utils.hexStringToUIColor(hex: "ffffff")
        pumpimg.font = UIFont.fontAwesome(ofSize: 25)
        pumpimg.text = String.fontAwesomeIcon(name: .bitbucket)
        
        foodimg.layer.cornerRadius = 25
        foodimg.clipsToBounds = true
        foodimg.textColor = utils.hexStringToUIColor(hex: "ffffff")
        foodimg.font = UIFont.fontAwesome(ofSize: 25)
        foodimg.text = String.fontAwesomeIcon(name: .cutlery)

        
        atmimg.layer.cornerRadius = 25
        atmimg.clipsToBounds = true
        atmimg.textColor = utils.hexStringToUIColor(hex: "ffffff")
        atmimg.font = UIFont.fontAwesome(ofSize: 25)
        atmimg.text = String.fontAwesomeIcon(name: .money)

        
        movieimg.layer.cornerRadius = 25
        movieimg.clipsToBounds = true
        movieimg.textColor = utils.hexStringToUIColor(hex: "ffffff")
        movieimg.font = UIFont.fontAwesome(ofSize: 25)
        movieimg.text = String.fontAwesomeIcon(name: .videoCamera)

        
        shopimg.layer.cornerRadius = 25
        shopimg.clipsToBounds = true
        shopimg.textColor = utils.hexStringToUIColor(hex: "ffffff")
        shopimg.font = UIFont.fontAwesome(ofSize: 25)
        shopimg.text = String.fontAwesomeIcon(name: .shoppingBag)

        
        drinkimg.layer.cornerRadius = 25
        drinkimg.clipsToBounds = true
        drinkimg.textColor = utils.hexStringToUIColor(hex: "ffffff")
        drinkimg.font = UIFont.fontAwesome(ofSize: 25)
        drinkimg.text = String.fontAwesomeIcon(name: .coffee)

        
        healthimg.layer.cornerRadius = 25
        healthimg.clipsToBounds = true
        healthimg.textColor = utils.hexStringToUIColor(hex: "ffffff")
        healthimg.font = UIFont.fontAwesome(ofSize: 25)
        healthimg.text = String.fontAwesomeIcon(name: .heartbeat)

        
        templeimg.layer.cornerRadius = 25
        templeimg.clipsToBounds = true
        templeimg.textColor = utils.hexStringToUIColor(hex: "ffffff")
        templeimg.font = UIFont.fontAwesome(ofSize: 25)
        templeimg.text = String.fontAwesomeIcon(name: .bank)

        
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "FFFFFF"), size: CGSize(width: 45, height: 45))
        
        filter.image = UIImage.fontAwesomeIcon(name: .filter, textColor: utils.hexStringToUIColor(hex: "FFFFFF"), size: CGSize(width: 45, height: 45))
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapBack))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap)
        
        let singleTap1 = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didFilterTap))
        singleTap1.numberOfTapsRequired = 1 // you can change this value
        filter.isUserInteractionEnabled = true
        filter.addGestureRecognizer(singleTap1)
        
        setTap()
        
    }
    
    func setTap(){
        foodimg.tag = 1
        drinkimg.tag = 2
        shopimg.tag = 3
        movieimg.tag = 4
        atmimg.tag = 5
        templeimg.tag = 6
        healthimg.tag = 7
        pumpimg.tag = 8
        
        
        let singleTapF = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapSearch(sender:)))
        singleTapF.numberOfTapsRequired = 1 // you can change this value
        foodimg.isUserInteractionEnabled = true
        foodimg.addGestureRecognizer(singleTapF)
        
        let singleTapD = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapSearch(sender:)))
        singleTapD.numberOfTapsRequired = 1 // you can change this value
        drinkimg.isUserInteractionEnabled = true
        drinkimg.addGestureRecognizer(singleTapD)
        
        let singleTapS = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapSearch(sender:)))
        singleTapS.numberOfTapsRequired = 1 // you can change this value
        shopimg.isUserInteractionEnabled = true
        shopimg.addGestureRecognizer(singleTapS)
        
        let singleTapM = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapSearch(sender:)))
        singleTapM.numberOfTapsRequired = 1 // you can change this value
        movieimg.isUserInteractionEnabled = true
        movieimg.addGestureRecognizer(singleTapM)
        
        let singleTapA = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapSearch(sender:)))
        singleTapA.numberOfTapsRequired = 1 // you can change this value
        atmimg.isUserInteractionEnabled = true
        atmimg.addGestureRecognizer(singleTapA)
        
        let singleTapT = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapSearch(sender:)))
        singleTapT.numberOfTapsRequired = 1 // you can change this value
        templeimg.isUserInteractionEnabled = true
        templeimg.addGestureRecognizer(singleTapT)
        
        let singleTapH = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapSearch(sender:)))
        singleTapH.numberOfTapsRequired = 1 // you can change this value
        healthimg.isUserInteractionEnabled = true
        healthimg.addGestureRecognizer(singleTapH)
        
        let singleTapP = UITapGestureRecognizer(target: self, action: #selector(NearMePlaces.didTapSearch(sender:)))
        singleTapP.numberOfTapsRequired = 1 // you can change this value
        pumpimg.isUserInteractionEnabled = true
        pumpimg.addGestureRecognizer(singleTapP)
               
    }
    
    func didTapSearch(sender:UITapGestureRecognizer){
        
        filterView.isHidden = true
        isFilterOpen = false
        
        if(Reachability.isConnectedToNetwork()){
            
            let utils = Utils()
        
         let tagNo = (sender.view?.tag)!
         searchType =  utils.getSearchTYpeString(tag: tagNo)
            
            getNearByPlaces {}
            
        }
        else{
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })

        }
    }
    
    func getNearByPlaces(completed: DownloadComplete){
        
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
            
            self.SearchList.removeAll()
            self.rad = "5000"
            
            let latlang = String(myLoc.coordinate.latitude) + "," + String(myLoc.coordinate.longitude)
            
            let rad = "&radius=" + self.rad
            let typ = "&types=" + self.searchType
            let apiKey = "&key=AIzaSyBUThKY77ySu0loIItwOPRWjwNk6pU4L_I"
            let loc = "location=" + latlang
       
        Current_Url = "\(nearbyPlaces)\(loc)\(rad)\(typ)\(apiKey)"
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
                        let allResults = dictionary["results"] as! Array<Dictionary<String, AnyObject>>
                        print("\(allResults)")
                        
                        var count = 10
                        
                        if(allResults.count < 10){
                            count = allResults.count
                        }
                        
                        for i in 0...(count){
                            
                            self.lookupAddressResults = allResults[i] as Dictionary<String, AnyObject>!
                            let geometry = self.lookupAddressResults["geometry"] as! Dictionary<String, AnyObject>
                            
                            let lat = ((geometry["location"] as! Dictionary<String, AnyObject>)["lat"] as! NSNumber).doubleValue
                            
                            let lang = ((geometry["location"] as! Dictionary<String, AnyObject>)["lng"] as! NSNumber).doubleValue
                            
                            let name = self.lookupAddressResults["name"] as! String
                            
                            // let openingHrs = self.lookupAddressResults["opening_hours"] as! Dictionary<String, AnyObject>
                            
                            // let isOpen = openingHrs["open_now"] as! Bool
                            
                            let addrs = self.lookupAddressResults["vicinity"] as! String
                            
                            let obj = NearByPlacesModel(Name: name, IsOpen: false, Lat: lat, Lang: lang, Address: addrs)
                            
                            self.SearchList.append(obj)
                            
                        }
                        self.view.isUserInteractionEnabled = true
                        self.hideActivityIndicator()
                        
                        self.mapView.clear()
                        
                        for i in 0...(count - 1){
                            let tempCoordinate = CLLocation(latitude: self.SearchList[i].lat, longitude: self.SearchList[i].lang)
                            self.setuplocationMarkerFriend(coordinate: tempCoordinate.coordinate, info: self.SearchList[i].name)
                        }
                        
                        

                    }
                    else {
                        self.view.isUserInteractionEnabled = true
                        self.hideActivityIndicator()
                        print(status1)
                    }
                }
   
                
            }
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
        }
        
        completed()
    }

    
    func didTapBack(){
        self.mapView.removeObserver(self, forKeyPath: "myLocation", context: nil)
        self.dismiss(animated: true, completion: {})
    }
    
    func didFilterTap(){
        if(isFilterOpen == true){
            filterView.isHidden = true
            isFilterOpen = false
        }
        else{
            filterView.isHidden = false
            isFilterOpen = true
        }
    }
    
    
    func setuplocationMarkerFriend(coordinate: CLLocationCoordinate2D, info: String) {
        let utils = Utils()
        
        locationMarker = GMSMarker(position: coordinate)
        let view1:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
        let uiImageView:UILabel  = UILabel(frame: CGRect(x: 55, y: 0, width: 40, height: 40))
        let info1:UITextView = UITextView(frame: CGRect(x: 0, y: 40, width: 150, height: 50))
        
        
        
       
        
        info1.backgroundColor = UIColor.clear
        info1.textColor = utils.hexStringToUIColor(hex: "555555")
        info1.font = UIFont(name: "Avenir", size: 8)
        info1.text = info
        info1.textAlignment = .center
        
        uiImageView.layer.cornerRadius = 21
        uiImageView.clipsToBounds = true
        uiImageView.textAlignment = .center
        
        utils.setMarkerImage(type: searchType, imageView: uiImageView)
        
        view1.addSubview(uiImageView)
        view1.addSubview(info1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 150, height: 75), false, 0)
        
        view1.drawHierarchy(in: CGRect(x: 0, y: 0, width: view1.bounds.size.width, height: view1.bounds.size.height), afterScreenUpdates: true)
        let markerimg:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        locationMarker.icon = markerimg
        locationMarker.map = mapView
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

