//
//  InterestVC.swift
//  MakeMePopular
//
//  Created by sachin shinde on 11/01/17.
//  Copyright © 2017 Realizer. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class InterestVC: UIViewController , UICollectionViewDelegate,UICollectionViewDataSource{
    
    @IBOutlet weak var submitInterest: UIButton!
    @IBOutlet weak var interestView: UICollectionView!
    var interests=[InterestModel]()
    var selectedInterest = [String]()
    
    @IBOutlet weak var skip: UILabel!
    @IBOutlet weak var back: UIImageView!
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUP()
        interestView.delegate = self
        interestView.dataSource = self
        
        let utils = Utils()
        utils.createGradientLayer(view: self.view)
        
        if(view.bounds.width > 320){
          if let layout = interestView.collectionViewLayout as? UICollectionViewFlowLayout {
            print("\(view.bounds.width)")
            let itemWidth = interestView.bounds.width / 3
            print("\(itemWidth)")
            let itemHeight = layout.itemSize.height
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.invalidateLayout()
          }
        }
        
    }
    
    func setUP(){
       
        let utils = Utils()
        
        utils.createGradientLayer(view: self.view)
        
        interests = utils.getInterests()
        
        submitInterest.layer.cornerRadius = 10
        submitInterest.layer.shadowOpacity = 0.5
        submitInterest.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        submitInterest.layer.shadowRadius = 5.0
        submitInterest.layer.shadowColor = UIColor.black.cgColor
        let isFromReg:Bool = UserDefaults.standard.value(forKey: "FromReg") as! Bool
        skip.isHidden = true
        
        if(isFromReg){
           
            let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(InterestVC.didSkipTapDetected))
            singleTap2.numberOfTapsRequired = 1 // you can change this value
            skip.isUserInteractionEnabled = true
            skip.addGestureRecognizer(singleTap2)
            
        }
        else{
            
            
            
            back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: utils.hexStringToUIColor(hex: "ffffff"), size: CGSize(width: 40, height: 45))
            
            let singleTap2 = UITapGestureRecognizer(target: self, action: #selector(InterestVC.didBackTapDetected))
            singleTap2.numberOfTapsRequired = 1 // you can change this value
            back.isUserInteractionEnabled = true
            back.addGestureRecognizer(singleTap2)
            
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
        
    }
    
    func didSkipTapDetected(){
        let pref = UserDefaults.standard
        pref.set(true, forKey: "IsLogin")
        pref.synchronize()
        self.performSegue(withIdentifier: "dashboard", sender: self)
    }
    
    func didBackTapDetected() {
        
        self.dismiss(animated: true, completion: {})
        
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
               
                
                if((res?.count)! > 0){
                    
                    
                        for i in 0...(self.interests.count - 1){
                            for j in 0...((res?.count)! - 1){
                                if(self.interests[i].interestName == res?[j].interestName){
                                    let tempModel = InterestModel(interest: self.interests[i].interestName, isselected: true)
                                    self.interests[i] = tempModel
                                    self.selectedInterest.append(self.interests[i]._interestName)
                                    break
                                }
                            }
                        }
                    
                    self.interestView.delegate = self
                    self.interestView.dataSource = self
                    self.interestView.reloadData()
                    
                }
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                
            }
            else{
                self.view.isUserInteractionEnabled = true
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Near Me Friend", message: "Failed to fetch user interest, please try after some time.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
            }
            
        }
        
        completed()
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var bgcolor = "00BCD4"
        if(!interests[indexPath.row].isSelected){
            bgcolor = "ffffff"
        }
        
        if let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCell", for: indexPath as IndexPath) as? InterestCell {
            
            let name = interests[indexPath.row].interestName
            let utils = Utils()
            
            cell.updateCell(interest: name, isSelected: interests[indexPath.row].isSelected)
            
            cell.backgroundColor = utils.hexStringToUIColor(hex: bgcolor)
            
            cell.layer.cornerRadius = 10
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowColor = UIColor.black.cgColor
            
            cell.layer.borderWidth = 2
            cell.layer.borderColor = utils.hexStringToUIColor(hex: "ffffff").cgColor

            
            return cell
        }
        else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let isselected = interests[indexPath.row].isSelected
        var selected = false
        var bgcolor = "ffffff"
        
        if(isselected == true){
            selected = false
            bgcolor = "00BCD4"
            for i in 0...(self.selectedInterest.count){
                if(self.selectedInterest[i] == interests[indexPath.row]._interestName){
                    self.selectedInterest.remove(at: i)
                    break
                }
            }
            
        }else{
            selected = true
            self.selectedInterest.append(interests[indexPath.row]._interestName)
        }
        
        let name = interests[indexPath.row].interestName
        let utils = Utils()
        
        if let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCell", for: indexPath as IndexPath) as? InterestCell {
            
            let i1 = InterestModel(interest: name, isselected: selected)
            interests[indexPath.row] = i1
            
            cell.updateCell(interest: interests[indexPath.row].interestName, isSelected: interests[indexPath.row].isSelected)
            cell.selectedBackgroundView?.backgroundColor = utils.hexStringToUIColor(hex: bgcolor)
            interestView.reloadData()
           
        }

    }
    
    
    
    @IBAction func submitInterstClick(_ sender: Any) {
        if(selectedInterest.count > 0){
            if(Reachability.isConnectedToNetwork()){
                self.showActivityIndicator()
        setUserInterest(completed: {}, interests: selectedInterest)
            }
            else {
                
                let credentialerror = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                
                credentialerror.addAction(cancelAction)
                self.present(credentialerror, animated: true, completion: {  })
                
            }

            
        }
        else{
            let noInterest = UIAlertController(title: "Track Request", message: "Please selct at leat 1 interest", preferredStyle: .alert )
           
            let cancleAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            noInterest.addAction(cancleAction)
            present(noInterest, animated: true, completion: {  })
        }
    }
    
    func setUserInterest(completed: DownloadComplete, interests:[String]){
        
        self.view.isUserInteractionEnabled = false
        
        let methodName = "SetInterest"
        Current_Url = "\(BASE_URL)\(methodName)"
        print(Current_Url)
        
        let current_url = URL(string: Current_Url)!
        var userId = ""
            userId = UserDefaults.standard.value(forKey: "UserID") as! String
        
        let parameters1 = ["userId":userId,"interestNameList":interests] as [String : Any]
        
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]
        
        print(current_url)
        
        Alamofire.request(current_url, method: .post, parameters: parameters1, encoding: JSONEncoding.default, headers: headers1).responseString{ response in
            
            let respo = response.response?.statusCode
            
            self.view.isUserInteractionEnabled = true
            
            if(respo == 200)
            {
                let pref = UserDefaults.standard
                pref.set(true, forKey: "IsLogin")
                pref.synchronize()
                self.hideActivityIndicator()
                self.performSegue(withIdentifier: "dashboard", sender: self)
            }
            else{
                self.hideActivityIndicator()
                let credentialerror = UIAlertController(title: "Interest", message: "Interest not set, please try after some time.", preferredStyle: .alert)
                
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


