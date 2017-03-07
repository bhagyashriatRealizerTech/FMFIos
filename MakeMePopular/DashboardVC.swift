//
//  DashboardVC.swift
//  MakeMePopular
//
//  Created by sachin shinde on 12/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import GoogleMaps
import Charts
import FontAwesome_swift
import Alamofire
import ObjectMapper
class DashboardVC:UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UINavigationControllerDelegate, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    var dashboard=["Emergency","Friend Near","Add Friend","Invite Friend","Places Near","Friend List","Notification","Chat","Album"]
    var  chcount:Int=0
    var frdcount:Int=0

    var trackingDay: [String]!
    let locationManager = CLLocationManager()
    var city:String = ""
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    @IBOutlet weak var grapfv: UIView!
    @IBOutlet weak var dashboardCV: UICollectionView!
    
    @IBOutlet weak var updateInteres: UILabel!
    @IBOutlet weak var logOut: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var viewProfile: UILabel!
    @IBOutlet weak var settingMainView: UIView!
    
    @IBOutlet weak var mainchartViewTop: NSLayoutConstraint!
    @IBOutlet weak var mainChartViewBottom: NSLayoutConstraint!
    @IBOutlet weak var chartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainCharViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainChartView: UIView!
    @IBOutlet weak var settingView: UIImageView!
    @IBOutlet weak var chartview: HorizontalBarChartView!
    var isSettingsOpen:Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
          print(version)
        }
        
        getdashbordcounts {
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)),name:NSNotification.Name(rawValue: "loadDash"), object: nil)
        dashboardCV.delegate = self
        dashboardCV.dataSource = self
        
        grapfv.layer.shadowOpacity = 0.5
        grapfv.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        grapfv.layer.shadowRadius = 5.0
        grapfv.layer.shadowColor = UIColor.black.cgColor
        
        dashboardCV.layer.shadowOpacity = 0.5
        dashboardCV.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        dashboardCV.layer.shadowRadius = 5.0
        dashboardCV.layer.shadowColor = UIColor.black.cgColor
      
        if(view.bounds.width > 320){
            if let layout = dashboardCV.collectionViewLayout as? UICollectionViewFlowLayout {
                print("\(view.bounds.width)")
                let itemWidth = dashboardCV.bounds.width / 3
                print("\(itemWidth)")
                let itemHeight = layout.itemSize.height
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.invalidateLayout()
            }
            
            mainCharViewHeight.constant = 215
            chartViewHeight.constant = 200
            mainChartViewBottom.constant = 40
            mainchartViewTop.constant = 30
            
        }

        
       self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = 50
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        else{
            let credentialerror = UIAlertController(title: "Location Service", message: "Please Enable Your location service to use this app", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
    
    }
    func loadList(notification: NSNotification)->Int{
        
        
        
        chcount=chcount+1
        return chcount
        
    }

    func setUpView(){
    
        
        setChart()
        
        settingMainView.isHidden = true
        
        let utils = Utils()
        
        settingView.image = UIImage.fontAwesomeIcon(name: .ellipsisV, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(DashboardVC.didTapSetting))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        settingView.isUserInteractionEnabled = true
        settingView.addGestureRecognizer(singleTap)
        
        let singleTap1 = UITapGestureRecognizer(target: self, action: #selector(DashboardVC.didTapViewProfile))
        singleTap1.numberOfTapsRequired = 1 // you can change this value
        viewProfile.isUserInteractionEnabled = true
        viewProfile.addGestureRecognizer(singleTap1)
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(DashboardVC.didTapLogout))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        logOut.isUserInteractionEnabled = true
        logOut.addGestureRecognizer(singleTap2)
        
        let singleTap3 = UITapGestureRecognizer(target: self, action: #selector(DashboardVC.didTapAbout))
        singleTap3.numberOfTapsRequired = 1 // you can change this value
        about.isUserInteractionEnabled = true
        about.addGestureRecognizer(singleTap3)
        
        let singleTap4 = UITapGestureRecognizer(target: self, action: #selector(DashboardVC.didTapInterests))
        singleTap4.numberOfTapsRequired = 1 // you can change this value
        updateInteres.isUserInteractionEnabled = true
        updateInteres.addGestureRecognizer(singleTap4)
        
        isSettingsOpen = false
    
        
    }
    
    func didTapSetting(){
        
        if(isSettingsOpen == false){
        settingMainView.isHidden = false
            isSettingsOpen = true
        }
        else{
            settingMainView.isHidden = true
            isSettingsOpen = false
        }
    }
    
    func didTapViewProfile(){
        
        self.performSegue(withIdentifier: "profile", sender: nil)
        
    }
    
    func didTapLogout(){
        logOut {}
    }
    
    func didTapAbout(){
        self.performSegue(withIdentifier: "about", sender: nil)
    }
    
    func didTapInterests(){
        
        UserDefaults.standard.set(false, forKey: "FromReg")
        UserDefaults.standard.synchronize()
        
        let storyboardName = "Main"
        let viewControllerID = "SetInterestVC"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        let controller:UIViewController = storyboard.instantiateViewController(withIdentifier: viewControllerID)
        self.present(controller, animated: true, completion: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
         NotificationCenter.default.addObserver(self, selector: #selector(DashboardVC.recievedNotification), name: NSNotification.Name(rawValue: "loadList"), object: nil)
        getdashbordcounts {
            
        }
        
         setUpView()
    }
    
    func recievedNotification(){
        
        let pref = UserDefaults.standard
        
        let type:String = pref.string(forKey: "Type")!
        let msg:String = pref.string(forKey: "MessageText")!
        
        if(type == "FriendRequest")
        {
            self.performSegue(withIdentifier: "friendrequest", sender: nil)
        }
        else if(type == "Emergency")
        {
            self.performSegue(withIdentifier: "notif", sender: nil)
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
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let location:CLLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            //print(placeMark.addressDictionary)
            
            // City
            if(placeMark != nil){
                var adrs = ""
                if(placeMark.locality != nil){
                self.city = placeMark.subAdministrativeArea! as String
                }
                
                if(placeMark.thoroughfare != nil){
                    adrs = placeMark.thoroughfare! as String
                    
                }
                if(placeMark.subThoroughfare != nil){
                    adrs = adrs + " " + placeMark.subThoroughfare! as String
                   
                }
                if(placeMark.subLocality != nil){
                    adrs = adrs + " " + placeMark.subLocality! as String
                    print(adrs)
                }
                print(self.city)
                
                
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let newDate = dateFormatter.string(from: Date())
                
                var firstBroadcast = dateFormatter.date(from: newDate)
               
                
                if(UserDefaults.standard.value(forKey: "locationBroadccast") != nil){
                    if(UserDefaults.standard.value(forKey: "locationBroadccast")as! String != ""  || UserDefaults.standard.value(forKey: "locationBroadccast")as! String != "nil"){
                    let dateString = UserDefaults.standard.value(forKey: "locationBroadccast") as! String
                    
                    firstBroadcast = dateFormatter.date(from: dateString)!
                    }
                }
                
                let pref = UserDefaults.standard
                pref.setValue(self.city, forKey: "UserCity")
                pref.setValue(adrs, forKey: "UserAdrs")
                pref.set(locValue.latitude, forKey: "latitude")
                pref.set(locValue.longitude, forKey: "longitude")
                pref.synchronize()
                
                let diff = Date().offsetFrom(date: firstBroadcast!)
                
                let diffArr = diff.components(separatedBy: ":")
                if(Int(diffArr[0])! > 0 || Int(diffArr[1])! > 0 || Int(diffArr[2])! > 29){
                    if(Reachability.isConnectedToNetwork())
                    {
                        pref.set(newDate, forKey: "locationBroadccast")
                        pref.synchronize()
                        let setlocapi = SetLocationAPI()
                        setlocapi.setCoOrdinates(completed: {}, coordinates: location, City: self.city)
                    }else {
                        
                        let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                        
                        credentialerror.addAction(cancelAction)
                        self.present(credentialerror, animated: true, completion: {  })
                        
                    }
                }
                
            }
            
        })
    }
    func getdashbordcounts(completed: @escaping DownloadComplete)
    {
        let methodName = "getDashboardBadgeCounts/"
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String

        Current_Url = "\(BASE_URL)\(methodName)\(userId)"
        
        
        let current_url = URL(string: Current_Url)!

        
        
              
        print(current_url)
        
        Alamofire.request(current_url, method: .get, encoding: JSONEncoding.default).responseJSON{ response in
            
            
            let result = response.result
            
            print(response)
            if let dict = result.value  as?  Dictionary<String,AnyObject>
                
            {
               
                
                if(!(dict["chatBadgeCount"] as? Int == 0))
                {
                    
                    self.chcount = (dict["chatBadgeCount"] as? Int)!
                    
                    UserDefaults.standard.set(self.chcount, forKey: "ChatCount")
                    print(self.chcount)
                }
                else{
                
                
                 UserDefaults.standard.set(0, forKey: "ChatCount")
                print(self.chcount)
                }
                
                
                
                if(!(dict["friendBadgeCount"] as? Int == 0 ))
                {
                    self.frdcount=(dict["friendBadgeCount"] as? Int)!
                    UserDefaults.standard.set(self.frdcount, forKey: "FriendCount")
                    print(self.frdcount)
                }
                else{
                
                  UserDefaults.standard.set(0, forKey: "FriendCount")
                    print(self.frdcount)
                }

                
                self.dashboardCV.reloadData()
            }
            
            completed()
        }

    
    
    
    }
    
    func setChart(){
        
        let today:Double = Double(UserDefaults.standard.value(forKey: "TodayTrack") as! String)!
        let lastWeek:Double = Double(UserDefaults.standard.value(forKey: "LastWeek") as! String)!
        let lastMonth:Double = Double(UserDefaults.standard.value(forKey: "LastMonth") as! String)!
        
        var counter:Double = 50
        if(today >= 50.0 || lastWeek >= 50.0 || lastMonth >= 50.0){
            counter = 100
        }
        
        
        let utils = Utils()
        let formato:BarChartFormatter = BarChartFormatter()
        
        self.chartview.drawBarShadowEnabled = false
        self.chartview.drawValueAboveBarEnabled = true
        
        
        self.chartview.maxVisibleCount = Int(counter)
        
        
        
        let xAxis  = self.chartview.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = utils.hexStringToUIColor(hex: "ffffff")
        xAxis.granularity = 10
        
        
        
        let leftAxis = self.chartview.leftAxis;
        leftAxis.drawAxisLineEnabled = true;
        leftAxis.drawGridLinesEnabled = true;
        leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        leftAxis.axisMaximum = counter
        leftAxis.enabled = true
        
        let rightAxis = self.chartview.rightAxis
        rightAxis.enabled = false;
        
        rightAxis.drawAxisLineEnabled = true;
        rightAxis.drawGridLinesEnabled = false;
        rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
        rightAxis.axisMaximum = counter
        
        let l = self.chartview.legend
        l.enabled =  true
        
        self.chartview.fitBars = true;
        
        let barWidth = 7.0
        let spaceForBar =  10.0;
        let count = 3
       

        
        let val = [lastMonth,lastWeek,today]
        
        let days = ["Last Month","Last Week","Today"]
        var yVals = [BarChartDataEntry]()
        
        for i in 0..<count{
            
            //yVals.append(BarChartDataEntry(x: , y: ), data: days)
            yVals.append(BarChartDataEntry(x: Double(i) * spaceForBar, y: Double(val[i]), data: days as AnyObject?))
            let _ = formato.stringForValue(Double(i), axis: xAxis)
        }
        xAxis.valueFormatter = formato
        let chartDataSet = BarChartDataSet(values: yVals, label: "Tracking")
        chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(dataSet: chartDataSet)
        self.chartview.xAxis.valueFormatter = xAxis.valueFormatter
        chartData.barWidth = barWidth
        self.chartview.data = chartData
        self.chartview.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        self.chartview.chartDescription?.text = ""
        self.chartview.chartDescription?.textColor = utils.hexStringToUIColor(hex: "ffffff")
        

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dashboard.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCell", for: indexPath as IndexPath) as? DashboardCell {
            
            let name = dashboard[indexPath.row]
            let utils = Utils()
             var chatcount:Int=0
            var frdcount:Int=0
            
            if(UserDefaults.standard.value(forKey: "ChatCount") != nil)
            {
           chatcount=(UserDefaults.standard.value(forKey: "ChatCount") as? Int)!
            }
            if(UserDefaults.standard.value(forKey: "FriendCount") != nil)
            {
           frdcount=(UserDefaults.standard.value(forKey: "FriendCount") as? Int)!
            }
         let c=chatcount as NSNumber
           let f=frdcount as NSNumber
            print(chatcount)
        print(frdcount)
            
            print(c)
            print(f)
            

            
            cell.updateCell(itemName: name,chatcount:c.stringValue,frdcount:f.stringValue)
            
            cell.layer.cornerRadius = 10
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowColor = UIColor.black.cgColor
            if(indexPath.row == 0){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"ef5350").cgColor
            }
            
            else if(indexPath.row == 1){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"9575cd").cgColor
            }
            else if(indexPath.row == 2){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"ffc107").cgColor
            }
            else if(indexPath.row == 3){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"f06292").cgColor
            }
            else if(indexPath.row == 4){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"66bb6a").cgColor
            }
            else if(indexPath.row == 5){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"42a5f5").cgColor
            }
            else if(indexPath.row == 6){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"800040").cgColor
            }
            else if(indexPath.row == 7){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"008080").cgColor
            }
            else if(indexPath.row == 8){
                cell.layer.backgroundColor = utils.hexStringToUIColor(hex:"FF8000").cgColor
            }
            
            return cell
        }
        else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row == 0){
            self.performSegue(withIdentifier: "emergency", sender: self)
        }
        else if(indexPath.row == 1){
            if(Reachability.isConnectedToNetwork()){
            self.performSegue(withIdentifier: "trackdialogue", sender: nil)
            }else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }

        }

        else if(indexPath.row == 2){
            self.performSegue(withIdentifier: "addfriend", sender: self)
        }
            
        else if(indexPath.row == 3){
            let textToShare = "Check out this app: Make Me Popular.. it's awesome"
            let shareString = "https://itunes.apple.com/us/app/find-me-friends/id1207779520?ls=1&mt=8"
            let objectsToShare = [textToShare, shareString] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
            
            /*if let myWebsite = NSURL(string: shareString) {
                let objectsToShare = [textToShare, myWebsite] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                //New Excluded Activities Code
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                //
                
            activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }*/
           
        }
        else if(indexPath.row == 4){
            
            self.performSegue(withIdentifier: "nearmeplaces", sender: self)
            
        }
        else if(indexPath.row == 5){
            
            self.performSegue(withIdentifier: "friendlist", sender: self)
            
        }
        else if(indexPath.row == 6){
            
            self.performSegue(withIdentifier: "notiflist", sender: self)
            
        }
        else if(indexPath.row == 7){
//            var m:Int=(UserDefaults.standard.value(forKey: "ChatCount") as? Int)!
//            print(m)
//            if(m == 0)
//            {
//                
//            }
//            else{
//                UserDefaults.standard.set(0, forKey: "ChatCount") 
//            }
            chcount=0
            self.performSegue(withIdentifier: "chat", sender: self)
            
        }
        
        
    }
    
    func logOut(completed: DownloadComplete){
        
        let methodName = "DeregisterFcmToken/"
        let userID = UserDefaults.standard.value(forKey: "UserID") as! String
        Current_Url = "\(ACCOUNT_URL)\(methodName)\(userID)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        print(current_url)
        
        
        let fcmtk:String=UserDefaults.standard.value(forKey: "FCMToken") as! String
        let headers1:HTTPHeaders = ["fcmToken":fcmtk]

        
        
        Alamofire.request(current_url, method: .put, parameters: nil, encoding: JSONEncoding.default, headers:headers1).responseJSON{ response in
            
            let respo = response.response?.statusCode
            
            
            if(respo == 200)
            {
                
                self.hideActivityIndicator()
                self.locationManager.stopUpdatingLocation()
                let appDomain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
                UserDefaults.standard.synchronize()
                
                self.performSegue(withIdentifier: "logout", sender: nil)
            }
            else{
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Add Friend", message: "Failed to fetch Interests, please try after some time.", preferredStyle: .alert)
                
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

extension Date {
    
    func offsetFrom(date:Date) -> String {
        
    
        let difference = Calendar.current.dateComponents([.day,.hour,.minute,.second], from: date, to: self)
       
        let day:Int = difference.day!
        let hour:Int = difference.hour!
        let minute:Int = difference.minute!
        let seconds:Int = difference.second!
        
        let diff = "\(day):\(hour):\(minute):\(seconds)"
        
        return diff
        
    }
    
}
