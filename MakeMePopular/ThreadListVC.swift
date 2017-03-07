
//
//  ThreadListVC.swift
//  MakeMePopular
//
//  Created by sachin shinde on 08/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//


import UIKit
import Alamofire
import AlamofireImage
import CoreData
import ObjectMapper

class ThreadListVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var chatview: UIView!
    var context:NSManagedObjectContext!
    @IBOutlet weak var hidelable: UILabel!
    @IBOutlet weak var hideview: UIView!
    @IBOutlet var mainview: UIView!
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var lableName: UILabel!
    @IBOutlet var threadview: UIView!
    @IBOutlet weak var menuview: UIView!
    @IBOutlet weak var leading: NSLayoutConstraint!
    var menushow=false
    var c:Int=0
     let dbMsg = DBThreadList()
    var listcount:Int!
    @IBOutlet weak var rightmenu: UIBarButtonItem!
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    
    var LastMsgList=[LastMsgDtls]()
    
    

    @IBOutlet weak var back: UIImageView!
    @IBOutlet var menudisply: UIView!
    
    @IBAction func click(_ sender: Any) {
        performSegue(withIdentifier: "squeselectuser", sender: nil)
    }
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
       
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ThreadListVC.didBackTapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap)
        
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.white, size: CGSize(width: 40, height: 45))
        
        if(LastMsgList.count==0)
        {
          tableview.isHidden=true
            hidelable.isHidden=false
            hideview.isHidden=false
        }
        else{
            tableview.reloadData()
           
            tableview.isHidden=false
            hidelable.isHidden=true
            hideview.isHidden=true
            
        }
     
      
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)),name:NSNotification.Name(rawValue: "loadThread"), object: nil)
 
        navigationController?.navigationBar.barTintColor=UIColor(red: 2/255, green: 174/255, blue: 239/255, alpha: 1)
        navigationController?.navigationBar.isHidden=false
        
        
        self.navigationController?.navigationBar.tintColor=UIColor.white
        
        
        self.hideActivityIndicator()
        
    }
    func didBackTapDetected() {
        
        self.dismiss(animated: true, completion: {})
        
    }
    func loadList(notification: NSNotification){
        
        
        if(!LastMsgList.isEmpty)
        {
            LastMsgList.removeAll()
            
        }
        
        
        loadingView.isHidden=false
        downloadthreadlistDetails {}
        loadingView.removeFromSuperview()
        loadingView.isHidden=true
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        spinner.backgroundColor=UIColor.white
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
   

            let backgroundImage = #imageLiteral(resourceName: "gradient_bg")
            let imageView = UIImageView(image: backgroundImage)
            
            self.tableview.backgroundView = imageView
            
            
            tableview.isHidden=false
            LastMsgList.removeAll()
            tableview.reloadData()
  

                if Reachability.isConnectedToNetwork() == true{
                    
                    if(!LastMsgList.isEmpty)
                    {
                        LastMsgList.removeAll()
                        tableview.reloadData()
                        
                    }
                    else{
                        getFriendList {}
                    //    self.LastMsgList=dbMsg.retriveallrecords()
                        downloadthreadlistDetails {}
                        
                    }

            
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
   
    
    
    
        func downloadthreadlistDetails(completed: @escaping DownloadComplete){
        let dbMsg = DBThreadList()
    
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Threadlist")
        
        let datesortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [datesortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        
        
        let uid = UserDefaults.standard.value(forKey: "UserID") as! String
        let m = Chat_URL + "GetThreadList"
        
        let time=dbMsg.getupdateddateofthread()
      
  
            let fcmtk:String=UserDefaults.standard.value(forKey: "FCMToken") as! String
            
            var headers:[String:String] = ["userId":uid,"Time":time,"fcmToken":fcmtk]
        if(time == ""){
            headers = ["userId":uid,"fcmToken":fcmtk]
        }
          var base_url:URL? = nil
        base_url = URL(string: m )
      print(base_url!)
        LastMsgList.removeAll()
        
        Alamofire.request(m,method: .get,headers: headers).responseJSON{
            
            response in
            print(response)
            let result = response.result
         
          //print(response)
            if(response.response?.statusCode==200)
            {
            if let dict = result.value  as?  [Dictionary<String,AnyObject>]
                
            {
                let res = Mapper<ThreadlistModel>().mapArray(JSONObject: dict)
                
                
              
                    if #available(iOS 10.0, *) {
                        
                      
                       
                        
                        if((res?.count)! > 0)
                        {
                            for i in 0...((res?.count)! - 1)
                            {
                                let msg = res?[i]
                                let isThreadPresent:Bool = dbMsg.getThread(threadId: (msg?.threadId)!)
                            
                                if(isThreadPresent == true)
                                {
                                    
                                    
                                    dbMsg.updatethreadlist(threadlist: msg!)
                                }
                                    
                                else{
                                    
                                    dbMsg.insertthreadlist(threadlist: msg!)
                                    
                                }
                            }
                        }
                    }
                    else {
                    
                    
                    }
                    
                
                    self.LastMsgList = dbMsg.retriveallrecords()
             
               
                    
                    
               
                if(self.LastMsgList.count != 0)
                {
                    self.tableview.isHidden=false
                    self.tableview.dataSource=self
                    self.tableview.delegate=self
                    self.tableview.reloadData()
                    self.hideActivityIndicator()
                    
                    self.loadingView.removeFromSuperview()
                    
                    if (self.tableview.contentSize.height < self.tableview.frame.size.height) {
                        self.tableview.isScrollEnabled = false;
                        if(self.LastMsgList.count>6)
                        {
                            self.tableview.isScrollEnabled = true;
                        }
                        
                        
                    }
                    else {
                        self.tableview.isScrollEnabled = true;
                    }
                    
                    
                }
                else
                {
                    self.tableview.isHidden=true
                    self.hidelable.isHidden=false
                    self.hideview.isHidden=false
                    
                }
                
                
                self.hideActivityIndicator()
                self.loadingView.backgroundColor=UIColor.white
                
            }
            }
            
        }
        
        completed()
        loadingView.backgroundColor=UIColor.white
        
        
        
        
        
        
    }
    @available(iOS 10.0, *)
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LastMsgList.count
    }
    
    @IBOutlet weak var initialName: UILabel!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LastMessageTableCell",for:indexPath) as? LastMessageTableCell
        {
            cell.backgroundColor = .clear

            let LastMsg=LastMsgList[indexPath.row]
            let dateformat1 = DateFormatter()
            dateformat1.dateFormat = "yyyy-MM-dd"
            dateformat1.locale = .current
            
            
            
            let dateobj = DateUtil()
            
            
            let d1 = LastMsg.LastMsgTime.components(separatedBy: "T")[0]
            
            
            let dateinput1 = dateformat1.date(from: d1)
            let dateip = dateformat1.string(from: dateinput1!)
            
            let datelocal=dateobj.getLocalDate(utcDate:LastMsg.LastMsgTime)
        
            
            let dateinput = dateobj.getDate(date: dateip, FLAG: "D",t:datelocal)
      
            
            
            
                      
    
          
            
            
            var c1:String=""
            if(c1 != "0")
            {
                c1 = LastMsg.UnreadCount
                
                
            }
            else if(c1=="0")
            {
                c1=" "
                
            }
           

            cell.updateCell(threadname: LastMsg.ThreadName, lastMsgtext: "\(LastMsg.LastMsgSender):\(LastMsg.Lastmsgtext)", lastMsgSenderImg: LastMsg.LastmsgSenderimage, LastMsgTime: dateinput,Unreadcount:c1,LastSenderName: LastMsg.LastMsgSender)
       
            return cell
            
            
            
        }
        else{
        }
        return UITableViewCell()
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let LastMsg=LastMsgList[indexPath.row]
        UserDefaults.standard.setValue(LastMsg.ThreadId, forKey: "ThreadID")
        UserDefaults.standard.setValue(LastMsg.receiverId, forKey: "ParticipantList")
        UserDefaults.standard.set(LastMsg.ThreadName, forKey: "ThreadName")
        
        UserDefaults.standard.set(LastMsg.InitiateId, forKey: "InitiateId")
        print(LastMsg.ThreadId)
        
        
        
        let isreceiverid:Bool=dbMsg.getreceiverId(receiverId: LastMsg.receiverId)
        if(isreceiverid==false)
        {
            print("not reciver")
        }
        
        
        
        dbMsg.updatebadgecount(threadlist:LastMsg.UnreadCount)
     
        LastMsg.UnreadCount="0"
        performSegue(withIdentifier: "SgueMessageCenter", sender: LastMsg)
        
    }
    
    func getFriendList(completed: @escaping DownloadComplete)
    {
        let friend1=FriendListDetail()
        
        
        //friend1.deleteallvalues()
        
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
                
                
                
                
            }
            
            completed()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SelectMessageCenterListVC
        {
            if let msg = sender as? LastMsgDtls{
               
         
                
                destination.LastThreadMsg = msg
                
            }
        }
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
    
    
    
}

