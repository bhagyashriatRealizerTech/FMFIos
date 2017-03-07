//
//  NotifiationListVC.swift
//  MakeMePopular
//
//  Created by Mac on 03/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class NotifiationListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ViewTitle: UILabel!
    @IBOutlet weak var imgF: UIImageView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var imgTS: UIImageView!
    @IBOutlet weak var imgER: UIImageView!
    @IBOutlet weak var imgFRR: UIImageView!
    @IBOutlet weak var imgFRA: UIImageView!
    @IBOutlet weak var imgE: UIImageView!
    @IBOutlet weak var close: UIImageView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterrequest: UISegmentedControl!
    @IBOutlet weak var notifTable: UITableView!
    @IBOutlet weak var filter: UIImageView!
    @IBOutlet weak var back: UIImageView!
    
    
    @IBOutlet weak var tsSV: UIStackView!
    @IBOutlet weak var erSV: UIStackView!
    @IBOutlet weak var fSV: UIStackView!
    
    @IBOutlet weak var frSV: UIStackView!
    @IBOutlet weak var faSV: UIStackView!
    @IBOutlet weak var eSV: UIStackView!
    var notificationList = [NotificationModel]()
    var notificationSent = [NotificationModel]()
    var notificationRecieved = [NotificationModel]()
    var isReceived:Bool = true
    var notifType = [String]()
    var notifTag:Int = 1
    
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
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(NotifiationListVC.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.notifTable.delegate = self
        self.notifTable.dataSource = self
        notifTable.isHidden = true
        
        filterView.isHidden = true
        
        setUPView()
        setUPFilterView()
        
        filterrequest.setTitleTextAttributes((segAttributes1 as! [AnyHashable : Any]), for: .selected)
        
        filterrequest.setTitleTextAttributes((segAttributes2 as! [AnyHashable : Any]), for: .normal)
        
        
    }
    
    
    func setUPView(){
        let utils = Utils()
        
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 45))
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didBackTapDetected))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap2)
        
        filter.image = UIImage.fontAwesomeIcon(name: .filter, textColor: utils.hexStringToUIColor(hex: "FFFFFF"), size: CGSize(width: 45, height: 45))
        
        let singleTap1 = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didFilterTap))
        singleTap1.numberOfTapsRequired = 1 // you can change this value
        filter.isUserInteractionEnabled = true
        filter.addGestureRecognizer(singleTap1)
        
        close.image = UIImage.fontAwesomeIcon(name: .times, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 35, height: 35))
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didCloseTapView))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        close.isUserInteractionEnabled = true
        close.addGestureRecognizer(singleTap)


    }
    
    
    func setUPFilterView(){
        
         let utils = Utils()
        
        filterView.layer.cornerRadius = 3
        filterView.layer.borderWidth = 4
        filterView.layer.borderColor = utils.hexStringToUIColor(hex: "32A7B6").cgColor
        
        btnDone.layer.cornerRadius = 4
        btnDone.layer.shadowOpacity = 0.5
        btnDone.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        btnDone.layer.shadowRadius = 5.0
        btnDone.layer.shadowColor = UIColor.black.cgColor
        
        fSV.tag = 1
        eSV.tag = 2
        faSV.tag = 3
        frSV.tag = 4
        erSV.tag = 5
        tsSV.tag = 6
        
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didFilterRowTap(sender:)))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        fSV.isUserInteractionEnabled = true
        fSV.addGestureRecognizer(singleTap)
        
        let singleTap1 = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didFilterRowTap(sender:)))
        singleTap1.numberOfTapsRequired = 1 // you can change this value
        eSV.isUserInteractionEnabled = true
        eSV.addGestureRecognizer(singleTap1)
        
        let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didFilterRowTap(sender:)))
        singleTap2.numberOfTapsRequired = 1 // you can change this value
        faSV.isUserInteractionEnabled = true
        faSV.addGestureRecognizer(singleTap2)
        
        let singleTap3 = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didFilterRowTap(sender:)))
        singleTap3.numberOfTapsRequired = 1 // you can change this value
        frSV.isUserInteractionEnabled = true
        frSV.addGestureRecognizer(singleTap3)
        
        let singleTap4 = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didFilterRowTap(sender:)))
        singleTap4.numberOfTapsRequired = 1 // you can change this value
        erSV.isUserInteractionEnabled = true
        erSV.addGestureRecognizer(singleTap4)
        
        let singleTap5 = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didFilterRowTap(sender:)))
        singleTap5.numberOfTapsRequired = 1 // you can change this value
        tsSV.isUserInteractionEnabled = true
        tsSV.addGestureRecognizer(singleTap5)
        
       
         ChangeCheck(imgV: imgF)
        
        notifType.removeAll()
        notifType.append(utils.getNotificationType(tag: 1))
        
        if(Reachability.isConnectedToNetwork()){
            getNotificationList(completed: {}, type: notifType)
        }else{
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

    }
    
    func ChangeCheck(imgV:UIImageView){
        
        let utils = Utils()
        imgF.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "32A7B6"), size: CGSize(width: 25, height: 25))
        imgE.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "32A7B6"), size: CGSize(width: 25, height: 25))
        imgFRA.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "32A7B6"), size: CGSize(width: 25, height: 25))
        imgFRR.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "32A7B6"), size: CGSize(width: 25, height: 25))
        imgER.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "32A7B6"), size: CGSize(width: 25, height: 25))
        imgTS.image = UIImage.fontAwesomeIcon(name: .circleO, textColor: utils.hexStringToUIColor(hex: "32A7B6"), size: CGSize(width: 25, height: 25))
        imgV.image = UIImage.fontAwesomeIcon(name: .checkCircleO, textColor: utils.hexStringToUIColor(hex: "32A7B6"), size: CGSize(width: 25, height: 25))

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let utils = Utils()
        utils.createGradientLayer(view: self.view)
    }
    
    func didTapView(){
        self.view.endEditing(true)
        filterView.isHidden = true
    }
    
    func didCloseTapView(){
        
        filterView.isHidden = true
    }
    
    func didFilterRowTap(sender:UITapGestureRecognizer){
        let tag = sender.view?.tag
        notifTag = tag!
        
        if(tag == 1){
           ChangeCheck(imgV: imgF)
        }
        else if(tag == 2){
            ChangeCheck(imgV: imgE)
        }
        else if(tag == 3){
            ChangeCheck(imgV: imgFRA)
        }
        else if(tag == 4){
            ChangeCheck(imgV: imgFRR)
        }
        else if(tag == 5){
            ChangeCheck(imgV: imgER)
        }
        else if(tag == 6){
            ChangeCheck(imgV: imgTS)
        }
        
    }
    
    func didBackTapDetected() {
        
        self.dismiss(animated: true, completion: {})
        
    }
    
    func didFilterTap(){
       filterView.isHidden = false
    }
    
    
    //Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return notificationList.count
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
        if let cell=tableView.dequeueReusableCell(withIdentifier: "NotifCell", for:indexPath) as? NotificationCell
            
        {
            
            cell.updateCell(notif: notificationList[indexPath.section] )
            cell.selectionStyle = .gray
            cell.isHighlighted = true
            cell.tag = indexPath.section
           
            
            let utils = Utils()
            
            cell.backgroundColor = UIColor.clear
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor
            cell.layer.cornerRadius = 5
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: 8.0, height: 7.0)
            cell.layer.shadowRadius = 10.0
            cell.layer.shadowColor = UIColor.black.cgColor
            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(NotifiationListVC.didtableRowTap(sender:)))
            singleTap.numberOfTapsRequired = 1 // you can change this value
            cell.isUserInteractionEnabled = true
            cell.addGestureRecognizer(singleTap)

            
            return cell
            
        }
        else{
            
            return UITableViewCell()
        }
    }
    
    
    func didtableRowTap(sender:UITapGestureRecognizer){
        
        let tag = sender.view?.tag
        
        let notifmodel = notificationList[tag!]
        
        self.performSegue(withIdentifier: "notificationdetail", sender: notifmodel)
        
    }
    
    
    
    func getNotificationList(completed: DownloadComplete,type:[String]){
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator()
        
        let methodName = "GetMyNotifications/"
        let userId = UserDefaults.standard.value(forKey: "UserID") as! String
        Current_Url = "\(BASE_URL)\(methodName)\(userId)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        
        let parameters1 = ["types":type] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            let respo = response.response?.statusCode
            let result = response.result
            
            self.notificationList.removeAll()
            self.notificationRecieved.removeAll()
            self.notificationSent.removeAll()
            
            print("\(result.value)")
            if(respo == 200)
            {
                let res = Mapper<NotificationModel>().mapArray(JSONObject: result.value)
                if((res?.count)! > 0){
                
                    for i in 0...((res?.count)! - 1){
                        if(res?[i].isReceived == true){
                        self.notificationRecieved.append((res?[i])!)
                        }
                        else{
                        self.notificationSent.append((res?[i])!)
                        }
                    }
                    if(self.isReceived == true){
                      self.notificationList = self.notificationRecieved
                    }
                    else{
                        self.notificationList = self.notificationSent
                    }
                    
                self.notifTable.isHidden = false
                self.notifTable.delegate = self
                self.notifTable.dataSource = self
                self.notifTable.reloadData()
                    
                    if(type[0] == "TrackingStarted"){
                        self.ViewTitle.text = "Tracking"
                    }
                    else if(type[0] == "EmergencyRecipt" || type[0] == "Emergency"){
                        self.ViewTitle.text = "Emergency"
                    }
                    else{
                        self.ViewTitle.text = "Friend Request"
                    }
                    
                }
                else{
                    self.notifTable.isHidden = true
                }
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
                let msgSend = UIAlertController(title: "Notifications", message: "Failed to process the request", preferredStyle: .alert )
                
                let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                msgSend.addAction(cancleAction)
                self.present(msgSend, animated: true, completion: {  })
                
            }
            
        }
        
        completed()
    }
    
    func showActivityIndicator() {
        
        
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
    
    @IBAction func filterRequestTap(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == 0){
            isReceived = true
            
            self.notificationList = self.notificationRecieved
            self.notifTable.delegate = self
            self.notifTable.dataSource = self
            self.notifTable.reloadData()
            
        }
        else{
            isReceived = false
            
            self.notificationList = self.notificationSent
            self.notifTable.delegate = self
            self.notifTable.dataSource = self
            self.notifTable.reloadData()
        }

    }
    
    
    @IBAction func btnDoneClick(_ sender: Any) {
        
        filterView.isHidden = true
        
        let utils = Utils()
        notifType.removeAll()
        notifType.append(utils.getNotificationType(tag: notifTag))
        
        if(Reachability.isConnectedToNetwork()){
            getNotificationList(completed: {}, type: notifType)
        }else{
            let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            credentialerror.addAction(cancelAction)
            self.present(credentialerror, animated: true, completion: {  })
            
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NotificationDetailVC
        {
            if let notifObj = sender as? NotificationModel{
                destination.notificationModel = notifObj
            }
            
        }
    }
}

