//
//  ContactList.swift
//  MakeMePopular
//
//  Created by Mac on 16/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//



import Foundation
class ContactList{
    private var _userId:String!
    private var _username:String!
    private var _thumbnailurl:String!
    private var  _friendId:String!
    private var _frienduserId:String!
    
    var userId : String{
        get {
            return _userId
            
        }
        set
        {
            _userId = newValue
        }
    }
    var FriendId : String{
        get {
            return _friendId
            
        }
        set
        {
            _friendId = newValue
        }
    }
    var frienduserId : String{
        get {
            return _frienduserId
            
        }
        set
        {
            _frienduserId = newValue
        }
    }
    
    
    var username:String
        {
        get{
            return _username
        }
        set{
            _username=newValue
        }
        
    }
    var thumbnailurl : String{
        get {
            if(_thumbnailurl != nil)
            {
                return _thumbnailurl
            }
            else {return ""}
            
        }
        set
        {
            _thumbnailurl = newValue
        }
    }
    
    init(userId:String,username:String,ThumbnailUrl:String,FriendId:String,FrienduserId:String)
    {
        _userId=userId
        _username=username
        _thumbnailurl=ThumbnailUrl
        _friendId=FriendId
        _frienduserId=FrienduserId
    }
    
}
