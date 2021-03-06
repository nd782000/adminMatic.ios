//
//  Image.swift
//  AdminMatic2
//
//  Created by Nick on 2/14/17.
//  Copyright © 2017 Nick. All rights reserved.
//


/*
import Foundation
import UIKit

class Image {
    
    var ID: String!
    var thumbPath: String!
    var mediumPath: String!
    var rawPath: String!
    var name: String!
    var width: String!
    var height: String!
    var description: String!
    
     
    
    var customer: String = "0"
    var customerName: String = "Unknown"
    var woID: String = "0"
    
    var albumID: String = "0"
    var leadTaskID: String = "0"
    var contractTaskID: String = "0"
    var taskID: String = "0"
    var equipmentID: String = "0"
    
    var usageID:String = "0"
    var vendorID:String = "0"
    
    
    var dateAdded: String!
    var createdBy: String!
    var type: String!
    
    var tags: String = ""
    
    var image: UIImage?
    
    var uploadProgress:Float = 0.0
    var uploadStatus:String = "Uploading..."
    
    var index = 0
    var liked = "0"
    var likes = "0"
    
   // var topImage:String = "1"
    
    
    
    required init( _id: String?, _thumbPath:String?, _mediumPath:String?, _rawPath:String?, _name:String?, _width:String?, _height:String?, _description:String?, _dateAdded:String?, _createdBy:String?, _type:String?) {
        //print(json)
        if _id != nil {
            self.ID = _id
        }else{
            self.ID = ""
        }
        if _thumbPath != nil {
            self.thumbPath = _thumbPath
        }else{
            self.thumbPath = ""
        }
        if _mediumPath != nil {
            self.mediumPath = _mediumPath
        }else{
            self.mediumPath = ""
        }
        if _rawPath != nil {
            self.rawPath = _rawPath
        }else{
            self.rawPath = ""
        }
        
       // print("rawPath = \(self.rawPath)")
        
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        
        if _width != nil {
            self.width = _width
        }else{
            self.width = ""
        }
        if _height != nil {
            self.height = _height
        }else{
            self.height = ""
        }
        if _description != nil {
            self.description = _description
            if(self.description == ""){
                self.description = "No description provided."
            }
        }else{
            self.description = "No description provided."
        }
        if _dateAdded != nil {
            self.dateAdded = _dateAdded
        }else{
            self.dateAdded = ""
        }
        if _createdBy != nil {
            self.createdBy = _createdBy
        }else{
            self.createdBy = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        

        
       

 
        
    }
    
    
    //simple init for fullView viewing only
    init( _path:String?) {
        //print(json)
        if _path != nil {
            self.rawPath = "https://adminmatic.com/uploads/general/" + _path!
            self.mediumPath = "https://adminmatic.com/uploads/general/medium/" + _path!
            self.thumbPath = "https://adminmatic.com/uploads/thumbs/" + _path!
        }else{
            self.rawPath = ""
            self.mediumPath = ""
            self.thumbPath = ""
        }
        
    }
    
    
    //init for equipment
    init(_ID:String?) {
        //print(json)
        if _ID != nil{
            self.ID = _ID
            self.rawPath = "https://adminmatic.com/uploads/general/Equipment(\(_ID!)).jpeg"
            self.mediumPath = "https://adminmatic.com/uploads/general/medium/Equipment(\(_ID!)).jpeg"
            self.thumbPath = "https://adminmatic.com/uploads/general/thumbs/Equipment(\(_ID!)).jpeg"
        }else{
            self.ID = ""
            self.rawPath = ""
            self.mediumPath = ""
            self.thumbPath = ""
        }
        
        
    }
    
    //init for equipment w/out pic
    init(_ID:String?, _noPicPath:String?) {
        //print(json)
        if _ID != nil{
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _noPicPath != nil {
            self.rawPath = _noPicPath!
            self.mediumPath = _noPicPath!
            self.thumbPath = _noPicPath!
        }else{
            self.rawPath = ""
            self.mediumPath = ""
            self.thumbPath = ""
        }
        
    }
    
    
    
    
}
*/


