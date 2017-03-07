//
//  LastmsgDtls.swift
//  MakeMePopular
//
//  Created by sachin shinde on 08/02/17.
//  Copyright © 2017 Realizer. All rights reserved.
//


import Foundation
class LastMsgDtls
{
    private var _LastMsgTime:String!
    private var _LastMsgSender:String!
    private var _Lastmsgtext:String!
    private var _LastmsgSenderimage:String!
    private var _ThreadName:String!
    private var _UnreadCount:String!
    private var _ThreadId:String!
    private var _receiverId:String!
    private var _initiateId:String
    private var _lastsenderbyId:String!
    var LastMsgTime : String{
        get {
            return _LastMsgTime
            
        }
        set
        {
            _LastMsgTime = newValue
        }
    }
    var receiverId : String{
        get {
            return _receiverId
            
        }
        set
        {
            _receiverId = newValue
        }
    }
    var lastsenderbyId : String{
        get {
            return _lastsenderbyId
            
        }
        set
        {
            _lastsenderbyId = newValue
        }
    }
    
    var ThreadId : String{
        get {
            return _ThreadId
            
        }
        set
        {
            _ThreadId = newValue
        }
    }
    
    var UnreadCount : String{
        get {
            return _UnreadCount
            
        }
        set
        {
            _UnreadCount = newValue
        }
    }
    
    var ThreadName : String{
        get {
            return _ThreadName
            
        }
        set
        {
            _ThreadName = newValue
        }
    }
    
    var LastMsgSender:String
        {
        get {
            return _LastMsgSender
            
        }
        set
        {
            _LastMsgSender = newValue
        }
        
        
     
        
    }
    var Lastmsgtext:String
        {
        get{
            return _Lastmsgtext
            
        }set{
            _Lastmsgtext=newValue
        }
        
       
        
    }
    var LastmsgSenderimage:String
        {
        get{
            return _LastmsgSenderimage
            
        }set{
            _LastmsgSenderimage=newValue
        }
        
    }
    var InitiateId : String{
        get {
            return _initiateId
            
        }
        set
        {
            _initiateId = newValue
        }
    }
    init(LastMsgSender:String,Lastmsgtext:String,LastMsgTime:String,LastmsgSenderimage:String,ThreadName:String,ThreadId:String,reciverId:String,InitiateId:String,UnreadCount:String,LastSenderId:String)
    {
        _LastMsgSender=LastMsgSender
        _Lastmsgtext=Lastmsgtext
        _LastMsgTime=LastMsgTime
        _LastmsgSenderimage=LastmsgSenderimage
        _ThreadName=ThreadName
        _ThreadId=ThreadId
        _receiverId=reciverId
        _initiateId=InitiateId
        _UnreadCount=UnreadCount
        _lastsenderbyId=LastSenderId
       
    }
    
    
}
