//
//  RegistrationVC.swift
//  MakeMePopular
//
//  Created by sachin shinde on 10/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import FontAwesome_swift
import TextFieldEffects
import Alamofire
import ObjectMapper
import FirebaseInstanceID
import FirebaseMessaging
import Firebase
import GoogleMaps

class RegistrationVC: UIViewController , UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, GMSMapViewDelegate{
    var dbmsg=DBMessageList()
    var dbth=DBThreadList()
 var friend1=FriendListDetail()
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fname: AkiraTextField!
    @IBOutlet weak var purpose: AkiraTextField!
    
    @IBOutlet weak var dob: AkiraTextField!
    @IBOutlet weak var gender: AkiraTextField!
    @IBOutlet weak var mobileno: AkiraTextField!
    @IBOutlet weak var emailid: AkiraTextField!
    @IBOutlet weak var lname: AkiraTextField!
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()

    
    let locationManager = CLLocationManager()
    
    var genderOption = ["Male", "Female", "Other"]
    var genderPickerView: UIPickerView!
    
    var purposeOption = ["Official", "Personal", "Both"]
    var purposePickerView: UIPickerView!
    
    var datePickerView:UIDatePicker!
    
    let imagePicker = UIImagePickerController()
    var city:String = ""
    var thumbnailURL:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setUpUI()
        
        
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        gender.inputView = genderPickerView

        purposePickerView.delegate = self
        purposePickerView.dataSource = self
        purpose.inputView = purposePickerView
        
        
        
        datePickerView.addTarget(self, action: #selector(RegistrationVC.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        dob.inputView = datePickerView
        datePickerView.maximumDate=NSDate() as Date
        imagePicker.delegate = self

        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(RegistrationVC.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        //let utils = Utils()
        //utils.createGradientLayer(view: self.view)
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "gradient_bg"))
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
            
                if(placeMark.locality != nil){
                   self.city = placeMark.subAdministrativeArea! as String
                    self.locationManager.stopUpdatingLocation()
                }
            }
            
        })
     }
    
    
    func didTapDetected() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    func setUpUI(){
        
        let utils = Utils()
        
        utils.createGradientLayer(view: self.view)
        
        profileImage.image = UIImage.fontAwesomeIcon(name: .user, textColor: utils.hexStringToUIColor(hex: "FFFFFF"), size: CGSize(width: 65, height: 65))
        
        
        genderPickerView = UIPickerView()
        genderPickerView.tag = 1
        genderPickerView.backgroundColor = utils.hexStringToUIColor(hex: "B2EBF2")
        
        purposePickerView = UIPickerView()
        purposePickerView.tag = 2
        purposePickerView.backgroundColor = utils.hexStringToUIColor(hex: "B2EBF2")
        
        datePickerView = UIDatePicker()
        datePickerView.backgroundColor = utils.hexStringToUIColor(hex: "B2EBF2")
        datePickerView.datePickerMode = .date
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(RegistrationVC.didTapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(singleTap)
        
        register.layer.shadowOpacity = 0.5
        register.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        register.layer.shadowRadius = 5.0
        register.layer.shadowColor = UIColor.black.cgColor
        
    }
    
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dob.text = dateFormatter.string(from: sender.date)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1){
        return genderOption.count
        }
        else{
            return purposeOption.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 1){
            return genderOption[row]
        }else{
           return purposeOption[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 1){
          gender.text = genderOption[row]
        }
        else{
           purpose.text = purposeOption[row]
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.backgroundColor = UIColor.gray
            self.profileImage.layer.cornerRadius = 33
            self.profileImage.clipsToBounds = true
            self.profileImage.image = pickedImage
            
           
            
            if let imageData = pickedImage.jpeg(.medium) {
                if((imageData.count/1024) < 1000){
                     thumbnailURL = imageData.base64EncodedString(options: .lineLength64Characters)
                }
                else{
                  if let imageData1 = pickedImage.jpeg(.low) {
                    if((imageData1.count/1024) < 1000){
                        thumbnailURL = imageData1.base64EncodedString(options: .lineLength64Characters)
                         }
                    }
                }
            }
            
    
        } else {
            
            //profileImage.image = nil
            print("Error occured")
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerClick(_ sender: Any) {
    
        var refreshedToken = ""
        if(FIRInstanceID.instanceID().token() != nil){
            refreshedToken = FIRInstanceID.instanceID().token()!
            print("InstanceIdToken: \(refreshedToken)")
            UserDefaults.standard.set(refreshedToken, forKey: "FCMToken")
            connectToFCM()
        }
        let device_id = UIDevice.current.identifierForVendor?.uuidString
        
        if(fname.text?.isEmpty)!{
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter First Name", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        else if(lname.text?.isEmpty)!{
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter Last Name", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        else if(emailid.text?.isEmpty)!{
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter Email Id", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        else if(isValidEmail(testStr: emailid.text!) == false){
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter valid Email Id", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        
        else if(mobileno.text?.isEmpty)!{
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter Mobile Number", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        else if(validateMobileNo(value: mobileno.text!) == false){
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter valid Mobile Number", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        else if(gender.text?.isEmpty)!{
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter gender", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        else if(dob.text?.isEmpty)!{
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter Date of birth", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        else if(purpose.text?.isEmpty)!{
            let credentialerror = UIAlertController(title: "Regisration", message: "Please enter Purpose", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
        }
        else{
            let userdetail = UserDetail()
            let email:String = emailid.text!
            let fname1:String = fname.text!
            let lname1:String = lname.text!
            let mobNo:String = mobileno.text!
            let dob1:String = dob.text!
            let Acctype:String = purpose.text!
            let gen:String = gender.text!
            if(refreshedToken == ""){
                refreshedToken = FIRInstanceID.instanceID().token()!
                print("InstanceIdToken: \(refreshedToken)")
                UserDefaults.standard.set(refreshedToken, forKey: "FCMToken")
                connectToFCM()
            }
            userdetail.setupValue(email: email, fname: fname1, lname: lname1, contactno: mobNo, dob: dob1, accountType:Acctype, gender: gen, thumbnailURL: thumbnailURL, createts: "\(Date())", lastcity: city, devId: device_id!, fcmregID: "\(refreshedToken)")
            
            if(Reachability.isConnectedToNetwork()){
                self.showActivityIndicator()
                dbth.deleteallvalues()
                friend1.deleteallvalues()
                dbmsg.deleteallvalues()
            registerUser(completed: {}, userdetail: userdetail)
            }
            else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }

        
        }
    }
    
    func registerUser(completed: DownloadComplete, userdetail:UserDetail){
        
        self.view.isUserInteractionEnabled = false
        
        let methodName = "RegisterUser"
        Current_Url = "\(ACCOUNT_URL)\(methodName)"
        print(userdetail.fcmRegId!)
        
        let current_url = URL(string: Current_Url)!
        
       
        let parameters1 = ["emailId":userdetail.emailId!,"fName":userdetail.fName!,"lName":userdetail.lName!,"contactNo":userdetail.contactNo!,"accountType":userdetail.accountType!,"gender":userdetail.gender!,"lastCity":userdetail.lastCity!,"dob":userdetail.dob!,"thumbnailUrl":userdetail.thumbnailUrl!,"deviceId":userdetail.deviceId!,"fcmRegId":userdetail.fcmRegId!] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            let result = response.result
            
            self.view.isUserInteractionEnabled = true
            
            if(response.response?.statusCode == 200){
                print("\(result.value)")
            if let dict = result.value as? [String: AnyObject]
            {
                
              let res = Mapper<UserDetail>().map(JSONObject: dict)
                let pref = UserDefaults.standard
                pref.set(res?.fName, forKey: "UserFName")
                pref.set(res?.lName, forKey: "UserLName")
                pref.set(res?.thumbnailUrl, forKey: "ProfilePic")
                pref.set(res?.gender, forKey: "Gender")
                pref.set(res?.userId, forKey: "UserID")
                pref.set(res?.dob, forKey: "BirthDate")
                pref.set(res?.emailId, forKey: "EmailID")
                pref.set(res?.contactNo, forKey: "MobNo")
                pref.setValue(res?.todayTrackedCount, forKey: "TodayTrack")
                pref.setValue(res?.lastWeekTrackedCount, forKey: "LastWeek")
                pref.setValue(res?.lastMonthTrackedCount, forKey: "LastMonth")
                pref.set(true, forKey: "FromReg")
                pref.synchronize()
                
                self.hideActivityIndicator()
                
              self.performSegue(withIdentifier: "interest", sender: self)
                
              }
            }
            else{
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Registration", message: "Registration Failed, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }

    func connectToFCM(){
        
        FIRMessaging.messaging().connect{ (error) in
            if(error != nil){
                print("Unable to connect\(error)")
            }
            else{
                print("Connected to FCM")
            }
            
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
    
    func isValidEmail(testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func validateMobileNo(value: String) -> Bool {
    var result = true
        if(value.characters.count == 10){
          let PHONE_REGEX = "^[0-9]+$"
          let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
          result =  phoneTest.evaluate(with: value)
        }
        else{
            result = false
        }
        
    return result
    }

}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
