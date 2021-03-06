//
//  NewEditEquipmentFieldViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/29/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

 
class NewEditEquipmentFieldViewController: UIViewController, UITextFieldDelegate, NoInternetDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    var delegate:EquipmentFieldListDelegate!
    
    var submitButton:UIBarButtonItem!
    
    var editsMade:Bool = false
    
    var field:String!
    var ID:String = "0"

    //name
    var name:String = ""
    var nameLbl:GreyLabel!
    var nameTxtField:PaddedTextField!

    var submitButtonBottom:Button = Button(titleText: "Submit")

    //init for new
    init(_field:String){
        super.init(nibName:nil,bundle:nil)
        self.field = _field
        print("new field name: \(name) ID: \(ID) field: \(String(describing: field))")
    }
    
    //init for edit
    init(_name:String,_ID:String,_field:String){
        super.init(nibName:nil,bundle:nil)
        
        self.name = _name
        self.ID = _ID
        self.field = _field
        print("edit field name: \(name) ID: \(ID)  field: \(String(describing: field))")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        /*
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(NewEditEquipmentFieldViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        self.layoutViews()
    }
    
    func layoutViews(){
        //print("layout views")
        if(self.ID == "0"){
            
            switch self.field {
            case "TYPE":
                title =  "New Type Field"
                break
            case "FUEL":
                title =  "New Fuel Field"
                break
            case "ENGINE":
                title =  "New Engine Field"
                break
            case "INSPECTION":
                title =  "New Inspection Field"
                break
            default:
                title =  "New Type Field"
                break
            }
        }else{
            switch field {
            case "TYPE":
                title =  "Edit Type Field"
                break
            case "FUEL":
                title =  "Edit Fuel Field"
                break
            case "ENGINE":
                title =  "Edit Engine Field"
                break
            case "INSPECTION":
                title =  "Edit Inspection Field"
                break
            default:
                title =  "Edit Type Field"
                break
            }
        }
        
        submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditEquipmentFieldViewController.submit))
        navigationItem.rightBarButtonItem = submitButton
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = "Name:"
        self.nameLbl.textAlignment = .left
        self.nameLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(nameLbl)
        if self.name == ""{
            self.nameTxtField = PaddedTextField(placeholder: "Name")
        }else{
            self.nameTxtField = PaddedTextField()
            self.nameTxtField.text = name
        }
        
        self.nameTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.nameTxtField.autocapitalizationType = .words
        self.nameTxtField.returnKeyType = .done
        self.nameTxtField.delegate = self
        self.nameTxtField.tag = 10
        safeContainer.addSubview(self.nameTxtField)
        
        self.submitButtonBottom.addTarget(self, action: #selector(NewEditEquipmentFieldViewController.submit), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.submitButtonBottom)
        
    
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let equipmentViewsDictionary = [
            "nameLbl":self.nameLbl,
            "nameTxt":self.nameTxtField,
            "submitBtn":self.submitButtonBottom
            ] as [String:AnyObject]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[nameLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[nameTxt]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[submitBtn]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(40)][nameTxt(40)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[submitBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        if self.field == "TYPE"{
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][nameTxt(30)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        textField.resignFirstResponder()
        if textField.tag == 10{
            textField.text = textField.text?.capitalized
        }
        if textField.tag == 20{
            textField.text = textField.text?.uppercased()
        }
        editsMade = true
        return true
    }
    
    func validateFields()->Bool{
        print("validate fields")
        if nameTxtField.text != nameTxtField.placeHolder{
            name = nameTxtField.text!
        }
        //name check
        if(name == ""){
            print("provide a name")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Field", _message: "Provide a Name")
            return false
        }
        return true
    }
    
    @objc func submit(){
        print("submit field")
        if CheckInternet.Connection() != true{
                   self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
                   return
               }
        if(!validateFields()){
            print("didn't pass validation")
            return
        }
        
        
        //validate all fields
        
        indicator = SDevIndicator.generate(self.view)!
       
        let parameters:[String:String]
        parameters = ["fieldID": self.ID, "addedBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)!, "fieldName": self.name, "field": self.field, "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/equipmentField.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("equipment field response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.json = JSON(json)
                    
                    if self.json["errorArray"][0]["error"].stringValue.count > 0{
                        self.layoutVars.playErrorSound()
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Error with Save", _message: self.json["errorArray"][0]["error"].stringValue)
                        self.indicator.dismissIndicator()
                        return
                    }
                    
                    self.layoutVars.playSaveSound()
                    let newEquipmentFieldID = self.json["equipmentFieldID"].stringValue
                    
                    self.ID = newEquipmentFieldID
                    self.editsMade = false // avoids the back without saving check
                    self.delegate.reDrawEquipmentFieldList()
                    self.goBack()
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
    }
    
    @objc func goBack(){
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                _ = self.navigationController?.popViewController(animated: false)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: false)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is called to remove the first responder for the text field.
    func resign() {
        self.resignFirstResponder()
    }
    
    
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
       }
}


