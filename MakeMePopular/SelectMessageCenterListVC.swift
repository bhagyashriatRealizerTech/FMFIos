//
//  SelectMessageCenterListVC.swift
//  MakeMePopular
//
//  Created by sachin shinde on 08/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//


import UIKit
import Alamofire
import FontAwesome_swift
import ObjectMapper
import CoreData



class SelectMessageCenterListVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate{
    @IBOutlet weak var contatname: UILabel!
    @IBOutlet weak var messageviewtop: NSLayoutConstraint!
    
    @IBOutlet weak var stviewcentery: NSLayoutConstraint!
    @IBOutlet weak var headerview: UIView!
    @IBOutlet weak var back: UIImageView!
    @IBOutlet weak var textmsg: UITextField!
    @IBOutlet weak var usernamemenu: UIBarButtonItem!
    @IBOutlet weak var sendbutton: UIButton!
    
    var LastMsg=[Message]()
    var MsgGroup=[[Message]]()
    var timelist=[String]()
    var Datelist=[Message]()
   
    var dateArray = [Date]()
    var unique=[String]()
    var uniqueday=[String]()
    var sec:String=""
    let dateobj = DateUtil()
    var c:Int=0
     var countsec:Int!
    let dbMsg = DBMessageList()
    private var   _lastthreadmsg:LastMsgDtls!
    var  LastThreadMsg : LastMsgDtls{
        get {
            return _lastthreadmsg
            
        }
        set
        {
            _lastthreadmsg = newValue
        }
    }
    
    var sendmsg=[Message]()
    var placeholderLabel : UILabel!
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    var th=DBThreadList()
    
    @IBAction func sendMsgClick(_ sender: AnyObject) {
       
        
        
        hideActivityIndicator()
        if(textmsg.text == "")
        {
            dismissKeyboard()
            let initiateNewThread = UIAlertController(title: "Message Center", message: "Please enter message", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            
            
            initiateNewThread.addAction(cancelAction)
            
            
            self.present(initiateNewThread, animated: true, completion: {  })
            hideActivityIndicator()
        }
        else{
            
          
            downloadSendMsgDetails {}
          loadingView.isHidden=true
            spinner.stopAnimating()
        }
       
        
    }
    
    @IBOutlet weak var MessageCenter: UITableView!
    @IBOutlet weak var headertop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
         MessageCenter.setNeedsLayout()
        MessageCenter.layoutIfNeeded()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(SelectMessageCenterListVC.didBackTapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(singleTap)
        back.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.white, size: CGSize(width: 40, height: 45))
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)),name:NSNotification.Name(rawValue: "loadMessage"), object: nil)
       
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMsg(notification:)),name:NSNotification.Name(rawValue: "ReceiveNotification"), object: nil)
        
        
        
        
        if Reachability.isConnectedToNetwork() == true{
            if(!LastMsg.isEmpty)
            {
                LastMsg.removeAll()
                MessageCenter.reloadData()
                
            }
            self.LastMsg = self.dbMsg.retriveallmessage(threadid: self.LastThreadMsg.ThreadId)
            
            unique.removeAll()
            
            timelist=dbMsg.retriveonlydates(threadid: LastThreadMsg.ThreadId)
  
            unique.removeAll()
            unique = Array(Set(timelist))
         
            unique.sort { (date1, date2) -> Bool in
                return date1.compare(date2) == ComparisonResult.orderedAscending
            }
            
           
            let countedSet = NSCountedSet()
            countedSet.addObjects(from: timelist)
            
            c=countedSet.count(for: unique)        //
           
          var p=0
            if(unique.count==1){
                
             self.Datelist.append(self.LastMsg[0])
                self.MsgGroup.append(self.Datelist)

            }
            else{
               // var u:Int=0
                if(unique.count == 0)
                {}
                else{
               
               for j in 0...unique.count-1{
                countedSet.count(for: unique[j])
             
                var c2=countedSet.count(for: unique[j])-1
              
               print(c2)
                if((unique.count-1)==0){
                    
                
                    self.Datelist.append(self.LastMsg[c2])

                }else{
                     c2=c2+p
                for k in p...c2{
//                    if(self.unique[j]==self.LastMsg[k].MsgTime){
                    
                        self.Datelist.append(self.LastMsg[k])
                        //}
                    
                      }
                     p=c2+1
                    
                }
                
                self.MsgGroup.append(self.Datelist)
                 Datelist.removeAll()
               
            }
            }
           

            }
            
            

            
        
            Datelist.removeAll()
            timelist.removeAll()
            downloadthreadlmsgDetails {}

            
        } else {
           
            
            let uialert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
            
            
            uialert.addAction(okAction)
            
            present(uialert, animated: true, completion: {  })
            
            hideActivityIndicator()
        }
        
        self.textmsg.delegate = self
        
        textmsg.layer.borderColor=UIColor.black.cgColor
        textmsg.layer.borderWidth=1
        textmsg.layer.cornerRadius=5
        
        
        
        
        contatname.text=LastThreadMsg.ThreadName
        
        
        loadingView.removeFromSuperview()
        loadingView.isHidden=true
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        spinner.backgroundColor=UIColor.white
        hideActivityIndicator()
        
     let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectMessageCenterListVC.dismissKeyboard))
        
        
        view.addGestureRecognizer(tap)
       
     
    }
    
    
    
    func didBackTapDetected() {
        
        self.dismiss(animated: true, completion: {})
        
    }
    
    
    
    func loadMsg(notification: NSNotification){
        
       let isRead:String=UserDefaults.standard.value(forKey: "IsRead") as! String
        
        let issend:String="true"
        let t:String=UserDefaults.standard.value(forKey: "ThreadID") as! String
        let newthid=UserDefaults.standard.value(forKey: "ThreadId") as! String

        let msgID:String=UserDefaults.standard.value(forKey: "MsgId") as! String
        let uid = UserDefaults.standard.value(forKey: "UserID") as! String
        
         let isdelever:String=UserDefaults.standard.value(forKey: "IsDeliver") as! String
        
         let msgid:Bool=self.dbMsg.getmessage(messageid: (msgID))
        
        let thid1:Bool=self.dbMsg.getThread(threadId: newthid)
       
        print(msgid)
        print(thid1)
        
        var isr:Bool=true
        if(t==newthid){
            isr=true
            //dbMsg.insertMessagelistNotice(messageId: msgID, senderId:s, timeStamp: lstMsgTime, message: lstMsgText, threadId: t, receiverId:uid, senderName: lstmsgSender, senderThumbnail: lstSenderImage)

            
            if(msgid==true){
                dbMsg.updatemessage(messageid: msgID, threadid: newthid, isread:isRead, isdelever: isdelever, issend: issend)
                dbMsg.updatealldelever(threadid: newthid)
                
                
                
                self.LastMsg=dbMsg.retriveallmessage(threadid: t)
                MessageCenter.reloadData()
            }
            
            let threadactive:Bool=dbMsg.getThread(threadId: newthid)
            print(newthid)
            
            
            if(threadactive==true)
            {
                
                
                self.LastMsg=dbMsg.retriveallmessage(threadid: t)
                
                
            }
            
            if(LastMsg.count>0)
            {
                loadingView.isHidden=true
                
                self.spinner.stopAnimating()
                self.spinner.isHidden=true
                self.spinner.color=UIColor.white
                self.spinner.removeFromSuperview()
                
                MessageCenter.dataSource=self
                MessageCenter.delegate=self
                MessageCenter.reloadData()
            }
            
            MessageCenter.scrollToLastRow(animated: true)
            
            
        }
        else{
            isr=false
            print("not done")
        }
        
        
        
     
        receivemessages(msgID: msgID, uid: uid, read: isr)
        
        
    }

    
    
    func loadList(notification: NSNotification){
          //show()
        let dbth=DBThreadList()
       
        
        spinner.startAnimating()
        loadingView.isHidden=false
        if(spinner.isAnimating)
        {
      self.show()
        }
        var isRead:Bool=false
   
        let t:String=UserDefaults.standard.value(forKey: "ThreadID") as! String
        let newthid=UserDefaults.standard.value(forKey: "THID") as! String
        let lstmsgSender=UserDefaults.standard.value(forKey: "SendBy") as! String
        let lstMsgTime=UserDefaults.standard.value(forKey: "Time") as! String
        let lstMsgText:String=UserDefaults.standard.value(forKey: "MSG") as! String
        let lstSenderImage:String=UserDefaults.standard.value(forKey: "SenderPic") as! String
        let initiatID:String=UserDefaults.standard.value(forKey: "InitiateID") as! String
        print(initiatID)
        let msgID:String=UserDefaults.standard.value(forKey: "MessageID") as! String
        let uid = UserDefaults.standard.value(forKey: "UserID") as! String
        let parID:String=UserDefaults.standard.value(forKey: "ParticipateID") as! String
        var s:String=""
        if(uid==initiatID){
            s=parID
        }
        else{
            s=initiatID
        }
        
        if(t==newthid){
            isRead=true
            dbMsg.updatealldelever(threadid: t)
            
          dbMsg.insertMessagelistNotice(messageId: msgID, senderId:s, timeStamp: lstMsgTime, message: lstMsgText, threadId: t, receiverId:uid, senderName: lstmsgSender, senderThumbnail: lstSenderImage, isread: true, isdelever: true, issend:false)
            
            
//            downloadthreadlmsgDetails {
//                
//            }
            
            self.spinner.stopAnimating()
            self.spinner.isHidden=true
            self.spinner.color=UIColor.white
            self.spinner.removeFromSuperview()
              loadingView.isHidden=true
            
            let threadactive:Bool=dbMsg.getThread(threadId: newthid)
            print(newthid)
            
            
            if(threadactive==true)
            {
                
                 loadingView.isHidden=true
                self.spinner.isHidden=true

         self.LastMsg=dbMsg.retriveallmessage(threadid: t)
               
                
                //=====
                
                self.unique.removeAll()
                self.timelist=self.dbMsg.retriveonlydates(threadid: self.LastThreadMsg.ThreadId)
                print(self.timelist)
                
                self.unique = Array(Set(self.timelist))
                print(self.unique)
                self.unique.sort { (date1, date2) -> Bool in
                    return date1.compare(date2) == ComparisonResult.orderedAscending
                }
                
               
                
                let countedSet = NSCountedSet()
                countedSet.addObjects(from: self.timelist)
                
                self.c=countedSet.count(for: self.unique)        //
                print(self.unique.count)
                
                self.MsgGroup.removeAll()
                
                var p:Int=0
                if(self.unique.count>1)
                {
                    for j in 0...self.unique.count-1{
                        countedSet.count(for: self.unique[j])
                        
                        print(countedSet.count(for: self.unique[j]))
                        var c2=countedSet.count(for: self.unique[j])-1
                        c2=c2+p
                        for k in p...c2{
                            
                            if(k>self.LastMsg.count)
                            {
                                
                                break
                            }
                            else{
                                self.Datelist.append(self.LastMsg[k])
                            }
                            //}
                            
                        }
                        p=c2+1
                        self.MsgGroup.append(self.Datelist)
                        self.Datelist.removeAll()
                        
                    }
                }
                else if(self.unique.count==0){
                    
                    print("no any msg")
                }
                else{
                    self.MsgGroup.append([self.LastMsg[0]])
                }
                print(self.MsgGroup.count)
                
                
                
                
                
                
                //-----------
                dbth.updatebadgecountthread(threadlist: t)
                dbth.updatebadgecount(threadlist: newthid)
            }
           
            if(LastMsg.count>0)
            {
                loadingView.isHidden=true

                self.spinner.stopAnimating()
                self.spinner.isHidden=true
                self.spinner.color=UIColor.white
                self.spinner.removeFromSuperview()

                MessageCenter.dataSource=self
                MessageCenter.delegate=self
               MessageCenter.reloadData()
            }
       
            MessageCenter.scrollToLastRow(animated: true)
           
            
                   }
        else{
            isRead=false
            print("not done")
           }
        
        

        hideActivityIndicator()
               receivemessages(msgID: msgID, uid: uid, read: isRead)
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
                let friend1=FriendListDetail()
        let userid:String = UserDefaults.standard.value(forKey: "UserID") as! String

        
        let receverid:String =
            LastThreadMsg.receiverId
        
        var ReceverId:String!
        
        let initiateid:String=LastThreadMsg.InitiateId
        
        
        if(userid==receverid)
        {
            ReceverId=initiateid
        }
        else{
            ReceverId=receverid
        }
        
       
        print(ReceverId)
        let rec:Bool=friend1.getfriends(friendId: ReceverId)
        if(rec==false)
        {
            self.textmsg.isEnabled=false
            
            
            self.textmsg.attributedPlaceholder=NSAttributedString(string: "No Longer Friend  ", attributes: [NSForegroundColorAttributeName:UIColor.black])
            
            self.sendbutton.isUserInteractionEnabled=false
        }
        else{
            
        }

            

        //showActivityIndicator()
        
    }
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        view.endEditing(true)
        //textmsg.resignFirstResponder()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.MessageCenter {
               
            
            } else {
                return
            }
            
        }
        view.endEditing(true)
        hideActivityIndicator()
      
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(self.LastMsg.count<5)
        {
            
            self.MessageCenter.scrollToMiddle(animated: true)
            
        }
        else{
            self.MessageCenter.scrollToLastRow(animated: true)
        }
        
        
        animateViewMoving(up: true, moveValue:240)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
        textmsg.resignFirstResponder()
        
        hideActivityIndicator()
        animateViewMoving(up: false, moveValue: 240)
 
        if(self.LastMsg.count<5)
        {
            self.MessageCenter.scrollToMiddle(animated: true)
        }
        else{
            self.MessageCenter.scrollToLastRow(animated: true)
        }
        
   sendMsgClick(self)
        
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("end editing")
        
        if(self.LastMsg.count<5)
        {
            self.MessageCenter.scrollToMiddle(animated: true)
        }
        else{
            self.MessageCenter.scrollToLastRow(animated: true)
        }
        
        
       dismissKeyboard()
        
        
               return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
      
        return true
    }
    
    @IBAction func exit(_ sender: Any) {
        textmsg.resignFirstResponder()
        let numberOfSections = self.MessageCenter.numberOfSections
        let numberOfRows = self.MessageCenter.numberOfRows(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: numberOfSections-1)
            self.MessageCenter.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textmsg.resignFirstResponder()
         showActivityIndicator()
        
        return true
    }
    
    func receivemessages(msgID:String,uid:String,read:Bool)
    {
        hideActivityIndicator()
     
        spinner.stopAnimating()
        let m = Chat_URL + "ReceiveMessage"
                var base_url:URL? = nil
        base_url = URL(string: m )
        let param:Parameters=["messageId":msgID,"userId":uid,"isRead":read]
        let headers1:HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "application/json"]

        Alamofire.request(base_url!,method: .put,parameters:param,encoding: JSONEncoding.default, headers: headers1).responseJSON{ response in
            
            self.hideActivityIndicator()
            
        }
    }
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        
        
        MessageCenter.scrollToLastRow(animated: true)
        messageviewtop.constant=0
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
   
        
        
        
        
        UITableView.beginAnimations("animateView", context: nil)
        
        UITableView.setAnimationBeginsFromCurrentState(true)
        UITableView.setAnimationDuration(movementDuration)
        
        self.MessageCenter.frame=self.MessageCenter.frame.offsetBy(dx: 0, dy:0)
         UITableView.commitAnimations()
        
        headertop.constant=0.0
        
        UIButton.beginAnimations("animateView", context: nil )
        UIButton.setAnimationBeginsFromCurrentState(true)
        UIButton.setAnimationDuration(movementDuration )
        self.sendbutton.frame=self.sendbutton.frame.offsetBy(dx: 0, dy: movement)
        
        
        UITextField.beginAnimations("animateView", context: nil)
        UITextField.setAnimationBeginsFromCurrentState(true)
        UITextField.setAnimationDuration(movementDuration )
        self.textmsg.frame = self.textmsg.frame.offsetBy(dx: 0, dy: movement)
        
        
        
          MessageCenter.scrollToLastRow(animated: true)
        
        UITextField.commitAnimations()
        UIButton.commitAnimations()

        
        
        
        
    }
    
    
    
    func downloadthreadlmsgDetails(completed: DownloadComplete){
        let m = Chat_URL + "GetThreadMessages"
        if(!self.spinner.isAnimating)
        {
            //self.showActivityIndicator()
            
        }
  
       
        var base_url:URL? = nil
        base_url = URL(string: m )
  
        let userid:String = UserDefaults.standard.value(forKey: "UserID") as! String
      
        let receverid:String =
            LastThreadMsg.receiverId
        
        var ReceverId:String!
        
        let initiateid:String=LastThreadMsg.InitiateId
        
        
        if(userid==receverid)
        {
            ReceverId=initiateid
        }
        else{
            ReceverId=receverid
        }
       
        var time=dbMsg.lastupdatetime(thid: LastThreadMsg.ThreadId,receiverid:ReceverId)
        if(time=="")
        {
            time=""
        }
        
        

        let param:Parameters=["threadId":LastThreadMsg.ThreadId,"searchText":"","LastMessageTime":"","UserId":userid]
        Alamofire.request(base_url!,method:.post,parameters:param,encoding: JSONEncoding.default).responseJSON{ response in
            let result = response.result
           

            
            print(response)
           
            
          
            self.spinner.backgroundColor=UIColor.white
            self.loadingView.isHidden=true
            self.textmsg.text = ""
            if(response.response?.statusCode==200){
            if let dict = result.value  as?  [Dictionary<String,AnyObject>]
                
            {
                
                let res = Mapper<MessageModel>().mapArray(JSONObject: dict)
                
                if((res?.count) != 0 )
                {
                    for i in 0...((res?.count)! - 1)
                    {
                        let msg = res?[i]
                        let msgid:Bool=self.dbMsg.getmessage(messageid: (msg?.messageId)!)
                        if(msgid==false)
                        {
                               self.dbMsg.insertMessagelist(messagelist: msg!)
                        }
                        else{
                            
                           
                        self.dbMsg.updatemessagemodel(messagelist: msg!)
                            
                           
                        }
                        
                    }
                    
                }
                
            }
            }
            
            self.LastMsg = self.dbMsg.retriveallmessage(threadid: self.LastThreadMsg.ThreadId)
            
            
            self.unique.removeAll()
            self.timelist=self.dbMsg.retriveonlydates(threadid: self.LastThreadMsg.ThreadId)
      
            
            self.unique = Array(Set(self.timelist))
         
            self.unique.sort { (date1, date2) -> Bool in
                return date1.compare(date2) == ComparisonResult.orderedAscending
            }
            
          
            let countedSet = NSCountedSet()
            countedSet.addObjects(from: self.timelist)
            
            self.c=countedSet.count(for: self.unique)        //
          
            
            self.MsgGroup.removeAll()
            
            var p:Int=0
            if(self.unique.count>1)
            {
            for j in 0...self.unique.count-1{
                countedSet.count(for: self.unique[j])
            
                
                var c2=countedSet.count(for: self.unique[j])-1
                c2=c2+p
                for k in p...c2{

                    if(k>self.LastMsg.count)
                    {
                        
                        break
                    }
                    else{
                    self.Datelist.append(self.LastMsg[k])
                    }
                   //}
                    
                }
                p=c2+1
                self.MsgGroup.append(self.Datelist)
                self.Datelist.removeAll()
                
               }
            }
            else if(self.unique.count==0){
       
            print("no any msg")
            }
            else{
                self.MsgGroup.append([self.LastMsg[0]])
            }
            
          

            self.spinner.backgroundColor=UIColor.white

            
            
            
            self.MessageCenter.reloadData()
            
            
            if (self.MessageCenter.contentSize.height < self.MessageCenter.frame.size.height) {
                self.MessageCenter.isScrollEnabled = false;
                self.hideActivityIndicator()
            }
            else {
                self.MessageCenter.isScrollEnabled = true;
                let numberOfSections = self.MessageCenter.numberOfSections
                let numberOfRows = self.MessageCenter.numberOfRows(inSection: numberOfSections-1)
                
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: numberOfSections-1)
                    self.MessageCenter.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
                    self.hideActivityIndicator()
                }
                
            }
            self.spinner.backgroundColor=UIColor.white
            
            self.hideActivityIndicator()
        }
        
        
        self.MessageCenter.dataSource=self
        self.MessageCenter.delegate=self
        
        
        
        
        completed()
        
        
    }
    func BoolToString(b: Bool?)->String { return b?.description ?? "<None>"}
    override func viewDidAppear(_ animated: Bool) {
        
        navigationController?.hidesBarsWhenKeyboardAppears = false
        
    }
    func downloadSendMsgDetails(completed: DownloadComplete){
        
        
    
       var messageId:String=""
        var threadId:String=""
    let friend1=FriendListDetail()
        
     
        
        let m = Chat_URL + "sendMessage"
        
        if(!self.spinner.isAnimating)
        {
            self.showActivityIndicator()
            
        }
        
        
        var base_url:URL? = nil
        base_url = URL(string: m )
        
        
        let userid:String = UserDefaults.standard.value(forKey: "UserID") as! String
        let receverid:String =
            LastThreadMsg.receiverId
        
        var ReceverId:String!
        
        let initiateid:String=LastThreadMsg.InitiateId
        
        
        if(userid==receverid)
        {
            ReceverId=initiateid
        }
        else{
            ReceverId=receverid
        }
        
        
        let msg:String=textmsg.text! as String
        textmsg.text=""
        let date = Date()
        let dt=DateUtil()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let d:String=dateformatter.string(from: date)
        
        
        dismissKeyboard()
        
        dateformatter.dateFormat="yyyy-MM-dd"
        
        
        let parameters: Parameters = ["senderId":userid,"timeStamp":d,"message":msg,"threadId":LastThreadMsg.ThreadId,"receiverId":ReceverId]
        
        
        Alamofire.request(base_url!,method: .post ,parameters:parameters,encoding:JSONEncoding.default).responseJSON{ response in
            self.hideActivityIndicator()
            print(response)
            
            
            
            let result=response.result
            if(response.response?.statusCode==200)
            {
                if let dict = result.value  as?  Dictionary<String,AnyObject>
                    
                {
                  
                    
                    if(!(dict["messageId"] as? String == nil))
                    {
                        
                        messageId = dict["messageId"] as! String
                     
                        UserDefaults.standard.set(messageId, forKey: "Messageid")
                        
                    }
                    else{ }
                    
                    
                    
                    if(!(dict["threadId"] as? String == nil ))
                    {
                        threadId=dict["threadId"] as! String
                        UserDefaults.standard.set(threadId, forKey: "SenderId")
                      
                    }
                    else{ }

              
                    }
                var pic:String=""
                
                
                
                
                let fnm:String=UserDefaults.standard.value(forKey: "UserFName") as! String
                let Lnm:String=UserDefaults.standard.value(forKey: "UserLName") as! String
                
                
                
                
                if((UserDefaults.standard.value(forKey: "ProfilePic") as! String) != "")
                {
                    pic=UserDefaults.standard.value(forKey: "ProfilePic") as! String
                }
                else{
                    pic=""
                }
                
                
                
                let datelocal=dt.getDate(date: d, FLAG: "D", t: d)
                
                let d2=datelocal.components(separatedBy: " ")[0]
                var m2:String=""
                var t1:String=""
                var msgget:Message!
                
                if((d2.components(separatedBy: ":")[0])=="" )
                {
                    t1=d
                }
                else
                {
                    m2=d2.components(separatedBy: ":")[0]
                    if(m2=="12")
                    {
                        t1=d
                    }
                    else
                    {
                        t1=d2+" "+"AM"
                    }
                    print(t1)
                    
                }

                
                
             //msgget=Message(MsgSender: fnm+" "+Lnm, msgtext: msg, MsgTime: d, msgSenderimage: pic, isRead:false , isdelever: false, isSend: true)
          
//                self.downloadthreadlmsgDetails {
//                                 }
//                
                
              self.dbMsg.insertMessagelistNotice(messageId: messageId, senderId: userid, timeStamp: d, message: msg, threadId:self.LastThreadMsg.ThreadId, receiverId: ReceverId, senderName: fnm+" "+Lnm, senderThumbnail: pic, isread: false, isdelever: false, issend: true)
                self.LastMsg=self.dbMsg.retriveallmessage(threadid: self.LastThreadMsg.ThreadId)
                self.MsgGroup.removeAll()
                
                self.unique.removeAll()
                
                self.timelist=self.dbMsg.retriveonlydates(threadid: self.LastThreadMsg.ThreadId)
                print(self.timelist)
                
                self.unique = Array(Set(self.timelist))
                print(self.unique)
                self.unique.sort { (date1, date2) -> Bool in
                    return date1.compare(date2) == ComparisonResult.orderedAscending
                }
                
                for date in self.unique{
                    print(date)
                }
                print(self.unique)
                let countedSet = NSCountedSet()
                countedSet.addObjects(from: self.timelist)
                
                self.c=countedSet.count(for: self.unique)        //
                print(self.unique.count)
                
                
                
                var p:Int=0
                if(self.unique.count>1)
                {
                    for j in 0...self.unique.count-1{
                        countedSet.count(for: self.unique[j])
                        
                        print(countedSet.count(for: self.unique[j]))
                        var c2=countedSet.count(for: self.unique[j])-1
                        c2=c2+p
                        for k in p...c2{
                            
                            if(k>self.LastMsg.count)
                            {
                                
                                break
                            }
                            else{
                                self.Datelist.append(self.LastMsg[k])
                            }
                            //}
                            
                        }
                        p=c2+1
                        self.MsgGroup.append(self.Datelist)
                        self.Datelist.removeAll()
                        
                    }
                }
                else if(self.unique.count==0){
                    
                    print("no any msg")
                }
                else{
                    self.MsgGroup.append([self.LastMsg[0]])
                }
                print(self.MsgGroup.count)
                
              //-------------------------------
                self.spinner.stopAnimating()
                self.spinner.isHidden=true
                self.spinner.color=UIColor.white
                self.spinner.removeFromSuperview()
                

            }
            
            if(response.response?.statusCode==410)
            {
                
                self.textmsg.isEnabled=false
                self.textmsg.attributedPlaceholder=NSAttributedString(string: "No Longer Friend  ", attributes: [NSForegroundColorAttributeName:UIColor.black])
                
                self.sendbutton.isUserInteractionEnabled=false
                
               
                if(userid==receverid)
                {
                    ReceverId=initiateid
                }
                else{
                    ReceverId=receverid
                }
                let isfriend:Bool=friend1.getfriends(friendId:ReceverId)
                if(isfriend == false)
                {
                    
                    
                    
                    //update....
                    
                }
                    
                else{
                    
                
                    friend1.deletsinglefriend(frienduserid: ReceverId)
                   
                    
                }
                
                
            }
            else{
                
                
            }
            self.spinner.stopAnimating()
            self.spinner.isHidden=true
            self.spinner.color=UIColor.white
            self.spinner.removeFromSuperview()
            self.MessageCenter.reloadData()
            self.textmsg.text=""
            
            if(self.LastMsg.count<5)
            {
               
                self.MessageCenter.scrollToMiddle(animated: true)
            }
            else{
              
                self.MessageCenter.scrollToLastRow(animated: true)
            }
            
            self.MessageCenter.scrollToLastRow(animated: true)

    }

        completed()
      
    }
    
    
    @IBOutlet weak var backbtn: UIBarButtonItem!
    @IBOutlet weak var lblmsgtime: UILabel!
    @IBOutlet weak var lblmsg: UILabel!
    @IBOutlet weak var lblusername: UILabel!
    @IBOutlet weak var imgsender: UIImageView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @IBOutlet weak var sendbtn: UIButton!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let dbmsg=DBMessageList()
       var c:Int!
        print(LastThreadMsg.ThreadId)
        timelist.removeAll()
        timelist=dbmsg.retriveonlydates(threadid: LastThreadMsg.ThreadId)
        print(timelist)
        unique.removeAll()
        unique = Array(Set(timelist))
        print(unique)
        unique.sort { (date1, date2) -> Bool in
            return date1.compare(date2) == ComparisonResult.orderedAscending
        }
        
        for date in unique{
            print(date)
        }

        let countedSet = NSCountedSet()
        countedSet.addObjects(from: timelist)
        
        c=countedSet.count(for: unique)        //
        print(unique.count)

        
        return unique.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        let dbmsg=DBMessageList()
    
        timelist.removeAll()
        timelist=dbmsg.retriveonlydates(threadid: LastThreadMsg.ThreadId)
         print(timelist)
        
       unique = Array(Set(timelist))
        unique.sort { (date1, date2) -> Bool in
            return date1.compare(date2) == ComparisonResult.orderedAscending
        }
        
        for date in unique{
            print(date)
            uniqueday.append(dateobj.getDateforday(date: date, FLAG: "D", t: date))
            
        }
    print(uniqueday)
       
        let countedSet = NSCountedSet()
        countedSet.addObjects(from: timelist)
        
        c=countedSet.count(for: uniqueday[section])
       
        
        print(c)
        countsec=c
        
        
        
        
        
     
   
        return  uniqueday[section]
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        
        let countedSet = NSCountedSet()
        countedSet.addObjects(from: timelist)
        
        c=countedSet.count(for: unique[section]
        )
        
        
        
    
        return countedSet.count(for: unique[section])
    }
    func hrgroup()
    {
        for i in 0...LastMsg.count-1{
            
//            if(LastMsg[i].MsgTime>60)
//            {
//                
//            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerText = UILabel()
    
       // headerText.adjustsFontSizeToFitWidth = true
       
        headerText.textAlignment = .center
     
        let dbmsg=DBMessageList()
        
        timelist.removeAll()
        timelist=dbmsg.retriveonlydates(threadid: LastThreadMsg.ThreadId)
        print(timelist)
        
        unique = Array(Set(timelist))
        unique.sort { (date1, date2) -> Bool in
            return date1.compare(date2) == ComparisonResult.orderedAscending
        }
        
        for date in unique{
            print(date)
            uniqueday.append(dateobj.getDateforday(date: date, FLAG: "D", t: date))
            
        }
        
        
    
        
       
       
      
        
        
        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[label]", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["label": headerText])
        
     headerText.addConstraints(constraint)
        
        
        
        
        print(uniqueday)
        headerText.text=uniqueday[section]
        return headerText
    }
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCenterCell",for:indexPath) as? MessageCenterCell
        {
            //let sec=indexPath.section
             let uid = UserDefaults.standard.value(forKey: "UserID") as! String
          
            
                if(MsgGroup.count>1)
                {
           let LastMsgtest=MsgGroup[indexPath.section][indexPath.row]
                    let dateformat1 = DateFormatter()
                    dateformat1.dateFormat = "yyyy-MM-dd"
                    let dateobj = DateUtil()
                    
                    
                    let d1=LastMsgtest.MsgTime.components(separatedBy: "T")[0]
                    
                    
                    
                    
                    let dateinput1=dateformat1.date(from: d1)
                    
                    
                    
                    
                    var dateinput:String!
                    var dtinput:String!
                    
                    
                    let dlocal=dateobj.getLocalDate(utcDate: LastMsgtest.MsgTime)
                    
                    
                    if(dateinput1 != nil)
                    {
                        dateinput=dateformat1.string(from: dateinput1!)
                        
                        
                        
                        
                        dtinput=dateobj.getDate(date: dateinput, FLAG: "D",t:dlocal)
                        
                    }
                    else{
                        
                        
                        
                        dtinput=dateobj.getDate(date: LastMsgtest.MsgTime, FLAG: "D",t:LastMsgtest.MsgTime)
                        
                        
                    }
                    
                    
                    cell.lbllastmsg.preferredMaxLayoutWidth = cell.lbllastmsg.frame.width
                    
                    cell.lbllastmsg?.numberOfLines = 0
                    cell.lbllastmsg?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    if(LastMsgtest.isDeliver==true)
                    {
                        cell.imageread.image=#imageLiteral(resourceName: "msg_delivered_img")
                    }
                  else  if(LastMsgtest.isRead==true)
                    {
                       cell.imageread.image=#imageLiteral(resourceName: "msg_read_img")
                    }
               

                    let fnm:String=UserDefaults.standard.value(forKey: "UserFName") as! String
                    let Lnm:String=UserDefaults.standard.value(forKey: "UserLName") as! String
                    
                    print(LastThreadMsg.LastMsgSender)
                    print(uid)

              
                    //for i in 0...MsgGroup.count-1{
                      //  let lst=MsgGroup[indexPath.section][indexPath.row-1]
                         // let lstmsgtime=lst.MsgTime
                           let currtime=dtinput
                    
                    //let m=lst.MsgTime.components(separatedBy: " ")[0].components(separatedBy: ":")[1]
                  
                    var txt:String=""
//                    if(LastMsgtest.MsgSender==fnm+" "+Lnm){
//                            for i in 0...MsgGroup.count-1{
//                                
//                                
//                               var p = LastMsgtest.MsgTime
//                        if(m1<"60")
//                        {
//                            
//                            
//                            //txt=LastMsg[(indexPath.row)].MsgTime
//                          //  print(txt)
//                            
//                           // txt=txt+" "+LastMsg[MsgGroup.count-1].msgtext
//                            
//                        }
//                        else{
//                            txt=LastMsgtest.msgtext
//                        }
//                        print(txt)
//
//                    }
//                      txt=txt+" "+LastMsgtest.msgtext                     // }
//                    }
//                    else{
//                        txt=LastMsgtest.msgtext
//                    }
//                
                    cell.updateCell(MsgSender: LastMsgtest.MsgSender, msgtext: LastMsgtest.msgtext, MsgTime: dtinput, msgSenderimage: LastMsgtest.msgSenderimage, isread: LastMsgtest.isRead, isdelever: LastMsgtest.isDeliver,initaiteid:LastThreadMsg.InitiateId,username:fnm+" "+Lnm)
                    txt=txt+""
                    
                    
                  
//                  if(LastMsgtest.receiverId==uid)
//                  {
//                    cell.imageread.isHidden
//                    }
                    
                    hideActivityIndicator()
                    

            }
                else{
                  let  LastMsgtest=LastMsg[indexPath.row]
                    let dateformat1 = DateFormatter()
                    dateformat1.dateFormat = "yyyy-MM-dd"
                    let dateobj = DateUtil()
                    
                    
                    let d1=LastMsgtest.MsgTime.components(separatedBy: "T")[0]
                    
                    
                    
                    
                    let dateinput1=dateformat1.date(from: d1)
                    
                    
                    
                    
                    var dateinput:String!
                    var dtinput:String!
                    
                    
                    let dlocal=dateobj.getLocalDate(utcDate: LastMsgtest.MsgTime)
                    
                    
                    if(dateinput1 != nil)
                    {
                        dateinput=dateformat1.string(from: dateinput1!)
                        
                        
                        
                        
                        dtinput=dateobj.getDate(date: dateinput, FLAG: "D",t:dlocal)
                        
                    }
                    else{
                        
                        
                        
                        dtinput=dateobj.getDate(date: LastMsgtest.MsgTime, FLAG: "D",t:LastMsgtest.MsgTime)
                        
                        
                    }
                    
                    
                    cell.lbllastmsg.preferredMaxLayoutWidth = cell.lbllastmsg.frame.width
                    
                    cell.lbllastmsg?.numberOfLines = 0
                    cell.lbllastmsg?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    

                    let fnm:String=UserDefaults.standard.value(forKey: "UserFName") as! String
                    let Lnm:String=UserDefaults.standard.value(forKey: "UserLName") as! String
                   cell.updateCell(MsgSender: LastMsgtest.MsgSender, msgtext: LastMsgtest.msgtext, MsgTime: dtinput, msgSenderimage: LastMsgtest.msgSenderimage, isread: LastMsgtest.isRead, isdelever: LastMsgtest.isDeliver,initaiteid:LastThreadMsg.InitiateId,username:fnm+" "+Lnm)
                    
                    hideActivityIndicator()
                    

            }

            
            
            return cell
            
            
        }
        hideActivityIndicator()
        
        return UITableViewCell()
        
    }
    func show(){
        
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
             self.spinner.stopAnimating()
   self.spinner.isHidden=true
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
        }
    }
    
    
    
    @IBAction func backbtnpresed(_ sender: AnyObject) {
        
        
        self.dismiss(animated: true) {}
            }
    
    
    
    
    
}
extension UITableView {
    func setOffsetToBottom(animated: Bool) {
        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height), animated: true)
    }
    
    
    func scrollToLastRow(animated: Bool) {
        
        
        
        if self.numberOfRows(inSection: 0) > 0 {
            self.scrollToRow(at: IndexPath(row: self.numberOfRows(inSection: 0) - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
        
    }
    func scrollToMiddle(animated: Bool) {
        
        
        
        if self.numberOfRows(inSection: 0) > 0 {
            self.scrollToRow(at: IndexPath(row: self.numberOfRows(inSection: 0) - 1, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
        
    }
    
    
}
extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
