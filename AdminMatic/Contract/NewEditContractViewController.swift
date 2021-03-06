//
//  NewEditContractViewController.swift
//  AdminMatic2
//
//  Created by Nick on 4/12/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView



import Foundation
import UIKit
import Alamofire
import SwiftyJSON


 
class NewEditContractViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate, EditContractDelegate, NoInternetDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    
    //var lead:Lead!
    var taskArray:[Task2]!
    var contract:Contract2!
    
    let dateFormatter = DateFormatter()
    
    
    var submitButton:UIBarButtonItem!
    
    var delegate:ContractListDelegate!
    var editDelegate:EditContractDelegate!
    var leadTaskDelegate:LeadTaskDelegate!
    //var editLeadDelegate:EditLeadDelegate!
    
    var statusIcon:UIImageView = UIImageView()
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray  = ["New","Sent","Awarded","Scheduled","Declined","Waiting","Canceled"]
    
    //customer search
    var customerSearchBar:UISearchBar = UISearchBar()
    var customerResultsTableView:TableView = TableView()
    var customerSearchResults:[String] = []
    
    var customerIDs = [String]()
    var customerNames = [String]()
    
    //title
    var titleLbl:GreyLabel!
    var titleTxtField:PaddedTextField!

    //charge type
    var chargeTypeLbl:GreyLabel!
    var chargeTypeTxtField:PaddedTextField!
    var chargeTypePicker: Picker!
    var chargeTypeArray = ["NC - No Charge", "FL - Flat Priced", "T & M - Time & Material"]
    
    //rep search
    var repLbl:GreyLabel!
    var repSearchBar:UISearchBar = UISearchBar()
    var repResultsTableView:TableView = TableView()
    var repSearchResults:[String] = []
    
  
    
    //requested by customer switch
    var reqByCustLbl:GreyLabel!
    var reqByCustSwitch:UISwitch = UISwitch()
    
    var notesLbl:GreyLabel!
    var notesView:UITextView!
    
    
    var keyBoardShown:Bool = false
    
    var editsMade:Bool = false
    
    var tableViewMode:String = ""
    
    
    //init for new
    init(){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        //for an empty lead to start things off
    }
    
    //init for edit
    init(_contract:Contract2){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        //for an empty lead to start things off
        self.contract = _contract
        
       // print("contract status = \(contract.status)")
    }
    
    //new from customer view
    init(_customer:String,_customerName:String){
        super.init(nibName:nil,bundle:nil)
        
        self.contract = Contract2(_ID: "0", _title: "", _status: "0", _createdBy: (appDelegate.loggedInEmployee?.ID)!)
        self.contract.statusName = "New"
        self.contract.chargeType = ""
        self.contract.customerID = _customer
        self.contract.customerName = _customerName
        self.contract.notes = ""
        self.contract.salesRep = ""
        self.contract.repName = ""
        self.contract.createDate = ""
        self.contract.subTotal = "0"
        self.contract.taxTotal = "0"
        self.contract.total = "0"
        self.contract.terms = ""
        self.contract.daysAged = "0"

    }
    
    //new from lead
    init(_lead:Lead2,_tasks: [Task2]){
        super.init(nibName:nil,bundle:nil)
       
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        /*
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(NewEditContractViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        showLoadingScreen()
    }
    
    
    func showLoadingScreen(){
        title = "Loading..."
        getPickerInfo()
    }
    
    func getPickerInfo(){
        //print("get picker info")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        indicator = SDevIndicator.generate(self.view)!
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
      
        //Get cust list
        var parameters:[String:AnyObject]
        parameters = ["sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject]
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/customers.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("customer response = \(response)")
            }
            .responseJSON() {
                response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let results = json["customers"] as? [[String: Any]] {
                    for result in results {
                        if let id = result["ID"] as? String {
                            self.customerIDs.append(id)
                        }
                        if let name = result["name"] as? String {
                            self.customerNames.append(name)
                        }
                    }
                }
                self.indicator.dismissIndicator()
                self.layoutViews()
            } catch {
                //print("Error deserializing JSON: \(error)")
            }
        }
        
      
        
    }
    
    
    func layoutViews(){
        //print("layout views")
        if(self.contract == nil){
            title =  "New Contract"
            submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditContractViewController.submit))
            
           
            self.contract = Contract2(_ID: "0", _title: "", _status: "0", _createdBy: "0")
            self.contract.statusName = "New"
            self.contract.chargeType = ""
            self.contract.customerID = ""
            self.contract.customerName = ""
            self.contract.notes = ""
            self.contract.salesRep = ""
            self.contract.repName = ""
            self.contract.createDate = ""
            self.contract.subTotal = "0"
            self.contract.taxTotal = "0"
            self.contract.total = "0"
            self.contract.terms = ""
            self.contract.daysAged = "0"
            
            
        }else{
            if(self.contract.ID == "0"){
                //coming from customer page
                title =  "New Contract"
                submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditContractViewController.submit))
            }else{
                title =  "Edit Contract #" + self.contract.ID
                submitButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(NewEditContractViewController.submit))
            }
            
        }
        navigationItem.rightBarButtonItem = submitButton
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        

        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusIcon)
        setStatus(status: self.contract.status)
        
        //status picker
        self.statusPicker = Picker()
        self.statusPicker.tag = 1
        self.statusPicker.delegate = self
        self.statusPicker.dataSource = self
        //set status
       self.statusPicker.selectRow(Int(self.contract.status)! - 1, inComponent: 0, animated: false)
        self.statusTxtField = PaddedTextField(placeholder: "")
        self.statusTxtField.textAlignment = NSTextAlignment.center
        self.statusTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.statusTxtField.delegate = self
        self.statusTxtField.tintColor = UIColor.clear
        self.statusTxtField.backgroundColor = UIColor.clear
        self.statusTxtField.inputView = statusPicker
        self.statusTxtField.layer.borderWidth = 0
        safeContainer.addSubview(self.statusTxtField)
        let statusToolBar = UIToolbar()
        statusToolBar.barStyle = UIBarStyle.default
        statusToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        statusToolBar.sizeToFit()
        let closeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContractViewController.cancelStatusInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setStatusButton = BarButtonItem(title: "Set Status", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContractViewController.handleStatusChange))
        statusToolBar.setItems([closeButton, spaceButton, setStatusButton], animated: false)
        statusToolBar.isUserInteractionEnabled = true
        statusTxtField.inputAccessoryView = statusToolBar
        
        
        //customer select
        customerSearchBar.placeholder = "Customer..."
        customerSearchBar.translatesAutoresizingMaskIntoConstraints = false
        
        customerSearchBar.layer.borderWidth = 1
        customerSearchBar.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        customerSearchBar.layer.cornerRadius = 4.0
        customerSearchBar.inputView?.layer.borderWidth = 0
        
        customerSearchBar.clipsToBounds = true
        
        customerSearchBar.backgroundColor = UIColor.white
        customerSearchBar.barTintColor = UIColor.white
        customerSearchBar.searchBarStyle = UISearchBar.Style.default
        customerSearchBar.delegate = self
        customerSearchBar.tag = 1
        safeContainer.addSubview(customerSearchBar)
        
        let custToolBar = UIToolbar()
        custToolBar.barStyle = UIBarStyle.default
        custToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        custToolBar.sizeToFit()
        let closeCustButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContractViewController.cancelCustInput))
        
        custToolBar.setItems([closeCustButton], animated: false)
        custToolBar.isUserInteractionEnabled = true
        customerSearchBar.inputAccessoryView = custToolBar
        
    
        if(self.customerIDs.count == 0){
            customerSearchBar.isUserInteractionEnabled = false
        }
        if(contract.customerName != ""){
            customerSearchBar.text = contract.customerName
        }
        
        self.customerResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.customerResultsTableView.delegate  =  self
        self.customerResultsTableView.dataSource = self
        self.customerResultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "customerCell")
        self.customerResultsTableView.alpha = 0.0
        
        //title
        self.titleLbl = GreyLabel()
        self.titleLbl.text = "Title:"
        safeContainer.addSubview(titleLbl)
        
        
        if(contract.title != ""){
            self.titleTxtField = PaddedTextField()
            self.titleTxtField.text = contract.title
        }else{
            
            self.titleTxtField = PaddedTextField(placeholder: "Title...")
        }
        
        self.titleTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.titleTxtField.delegate = self
        self.titleTxtField.tag = 2
        self.titleTxtField.autocapitalizationType = .words
        safeContainer.addSubview(self.titleTxtField)
        
        
        //charge type
        self.chargeTypeLbl = GreyLabel()
        self.chargeTypeLbl.text = "Charge Type:"
        safeContainer.addSubview(chargeTypeLbl)
        
        self.chargeTypePicker = Picker()
        self.chargeTypePicker.delegate = self
        self.chargeTypePicker.dataSource = self
        self.chargeTypePicker.tag = 2
        
        self.chargeTypeTxtField = PaddedTextField(placeholder: "Charge Type...")
        self.chargeTypeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.chargeTypeTxtField.delegate = self
        self.chargeTypeTxtField.tag = 3
        self.chargeTypeTxtField.inputView = chargeTypePicker
        safeContainer.addSubview(self.chargeTypeTxtField)
        
        let chargeTypeToolBar = UIToolbar()
        chargeTypeToolBar.barStyle = UIBarStyle.default
        chargeTypeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        chargeTypeToolBar.sizeToFit()
        let closeChargeTypeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContractViewController.cancelChargeTypeInput))
        
        let setChargeTypeButton = BarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContractViewController.handleChargeTypeChange))
        chargeTypeToolBar.setItems([closeChargeTypeButton, spaceButton, setChargeTypeButton], animated: false)
        chargeTypeToolBar.isUserInteractionEnabled = true
        chargeTypeTxtField.inputAccessoryView = chargeTypeToolBar
        
        
        if(contract.chargeType != ""){
            chargeTypeTxtField.text = chargeTypeArray[Int(contract.chargeType!)! - 1]
            self.chargeTypePicker.selectRow(Int(self.contract.chargeType!)! - 1, inComponent: 0, animated: false)
        }
        
        //sales rep
        self.repLbl = GreyLabel()
        self.repLbl.text = "Sales Rep:"
        
        safeContainer.addSubview(repLbl)
        
        
        
        repSearchBar.placeholder = "Sales Rep..."
        repSearchBar.translatesAutoresizingMaskIntoConstraints = false
        //customerSearchBar.layer.cornerRadius = 4
        
        repSearchBar.layer.borderWidth = 1
        repSearchBar.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        repSearchBar.layer.cornerRadius = 4.0
        repSearchBar.inputView?.layer.borderWidth = 0
        
        repSearchBar.clipsToBounds = true
        
        repSearchBar.backgroundColor = UIColor.white
        repSearchBar.barTintColor = UIColor.white
        repSearchBar.searchBarStyle = UISearchBar.Style.default
        repSearchBar.delegate = self
        repSearchBar.tag = 2
        safeContainer.addSubview(repSearchBar)
        
        
        let repToolBar = UIToolbar()
        repToolBar.barStyle = UIBarStyle.default
        repToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        repToolBar.sizeToFit()
        let closeRepButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContractViewController.cancelRepInput))
        
        repToolBar.setItems([closeRepButton], animated: false)
        repToolBar.isUserInteractionEnabled = true
        repSearchBar.inputAccessoryView = repToolBar
        
        
        
        
        if(self.appDelegate.salesRepArray.count == 0){
            repSearchBar.isUserInteractionEnabled = false
        }
        if(contract.repName != ""){
            repSearchBar.text = contract.repName
        }
        
        
        
        self.repResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.repResultsTableView.delegate  =  self
        self.repResultsTableView.dataSource = self
        self.repResultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "repCell")
        self.repResultsTableView.alpha = 0.0
        
        
        
        //notes
        self.notesLbl = GreyLabel()
        self.notesLbl.text = "Notes:"
        safeContainer.addSubview(self.notesLbl)
        
        self.notesView = UITextView()
        self.notesView.layer.borderWidth = 1
        self.notesView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.notesView.layer.cornerRadius = 4.0
        //self.notesView.returnKeyType = .done
        self.notesView.text = self.contract.notes
        self.notesView.font = layoutVars.smallFont
        self.notesView.isEditable = true
        self.notesView.delegate = self
        self.notesView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.notesView)
        
        let notesToolBar = UIToolbar()
        notesToolBar.barStyle = UIBarStyle.default
        notesToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        notesToolBar.sizeToFit()
        let closeNotesButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditContractViewController.cancelNotesInput))
        
        notesToolBar.setItems([closeNotesButton], animated: false)
        notesToolBar.isUserInteractionEnabled = true
        self.notesView.inputAccessoryView = notesToolBar
        
        safeContainer.addSubview(self.customerResultsTableView)
        safeContainer.addSubview(self.repResultsTableView)
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150] as [String:Any]
        
        //auto layout group
        let dictionary = [
            "statusIcon":self.statusIcon,
            "statusTxtField":self.statusTxtField,
            "customerSearchBar":self.customerSearchBar,
            "customerTable":self.customerResultsTableView,
            "titleLbl":self.titleLbl,
            "titleTxtField":self.titleTxtField,
            
            "chargeTypeLbl":self.chargeTypeLbl,
            "chargeTypeTxtField":self.chargeTypeTxtField,
            
            "repLbl":self.repLbl,
            "repSearchBar":self.repSearchBar,
            "repTable":self.repResultsTableView,
        
            "notesLbl":self.notesLbl,
            "notesView":self.notesView
            ] as [String:AnyObject]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusIcon(40)]-15-[customerSearchBar]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[customerTable]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLbl(48)][titleTxtField]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chargeTypeLbl(116)][chargeTypeTxtField]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[repLbl(80)]-10-[repSearchBar]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[repTable]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notesLbl]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notesView]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
        
        
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: dictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)]-10-[titleLbl(40)]-10-[chargeTypeLbl(40)]-10-[repLbl(40)]-10-[notesLbl(40)][notesView]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)][customerTable]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)]-10-[titleLbl(40)]-10-[chargeTypeLbl(40)]-10-[repLbl(40)][repTable]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)]-10-[titleTxtField(40)]-10-[chargeTypeTxtField(40)]-10-[repLbl(40)][repTable]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)]-10-[titleTxtField(40)]-10-[chargeTypeTxtField(40)]-10-[repSearchBar(40)]-10-[notesLbl(40)][notesView]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
        
    }
    
    @objc func cancelStatusInput(){
        //print("Cancel Cust Input")
        self.statusTxtField.resignFirstResponder()
    }
    
    
    @objc func cancelCustInput(){
        //print("Cancel Cust Input")
        self.customerSearchBar.resignFirstResponder()
        self.customerResultsTableView.alpha = 0.0
    }
    
    
    @objc func cancelChargeTypeInput(){
        //print("Cancel Charge Type Input")
        self.chargeTypeTxtField.resignFirstResponder()
    }
    
    
    @objc func cancelRepInput(){
        //print("Cancel Rep Input")
        self.repSearchBar.resignFirstResponder()
        self.repResultsTableView.alpha = 0.0
    }
    
    @objc func cancelNotesInput(){
        //print("Cancel Notes Input")
        self.notesView.resignFirstResponder()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {        //print("textFieldDidBeginEditing")
        
      
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //print("textFieldDidEndEditing")
        editsMade = true
       
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
   
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        //print("pickerview tag: \(pickerView.tag)")
        var count:Int = 0
        if(pickerView.tag == 1){
            count = self.statusArray.count
        }else{
            count = self.chargeTypeArray.count
        }
        return count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        //print("pickerview tag: \(pickerView.tag)")
        let myView = UIView(frame: CGRect(x:0, y:0, width:pickerView.bounds.width - 30, height:60))
        
        var rowString = String()
        if(pickerView.tag == 1){
            let myImageView = UIImageView(frame: CGRect(x:0, y:0, width:50, height:50))
            rowString = statusArray[row]
            switch row {
            case 0:
                myImageView.image = UIImage(named:"unDoneStatus.png")
                break
            case 1:
                myImageView.image = UIImage(named:"inProgressStatus.png")
                break
            case 2:
                myImageView.image = UIImage(named:"acceptedStatus.png")
                break;
            case 3:
                myImageView.image = UIImage(named:"doneStatus.png")
                break
            case 4:
                myImageView.image = UIImage(named:"cancelStatus.png")
                break
            case 5:
                myImageView.image = UIImage(named:"waitingStatus.png")
                break
            case 6:
                myImageView.image = UIImage(named:"cancelStatus.png")
                break
            default:
                myImageView.image = nil
            }
            let myLabel = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
            myLabel.font = layoutVars.smallFont
            myLabel.text = rowString
            myView.addSubview(myLabel)
            myView.addSubview(myImageView)
            
        }else{
            
            
            rowString = chargeTypeArray[row]
            
            let myLabel = UILabel(frame: CGRect(x:0, y:0, width:pickerView.bounds.width, height:60 ))
            myLabel.font = layoutVars.smallFont
            myLabel.textAlignment = .center
            myLabel.text = rowString
            myView.addSubview(myLabel)
            
        }
        return myView
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(pickerView.tag == 1){
            contract.status = "\(row + 1)"
        }
    }
    
    func cancelPicker(){
        self.statusTxtField.resignFirstResponder()
        self.chargeTypeTxtField.resignFirstResponder()
    }
    
    @objc func handleStatusChange(){
        self.statusTxtField.resignFirstResponder()
        contract.status = "\(self.statusPicker.selectedRow(inComponent: 0))"
        setStatus(status: contract.status)
        editsMade = true
    }
    //["New","Sent","Accepted","Scheduled","Declined","Waiting","Canceled"]
    func setStatus(status: String) {
        //print("set status \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "1":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"acceptedStatus.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        case "4":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        case "5":
            let statusImg = UIImage(named:"waitingStatus.png")
            statusIcon.image = statusImg
            break;
        case "6":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        default:
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
    
    
    
    @objc func handleChargeTypeChange(){
        //print("handle chargeType change")
        self.chargeTypeTxtField.resignFirstResponder()
        
        //warn users about items being set to $0 on change to NC
        if "\(self.chargeTypePicker.selectedRow(inComponent: 0) + 1)" == "1" && self.contract.ID != "0"{
            let alertController = UIAlertController(title: "Set All Items to NO CHARGE?", message: "Setting the contract to NO CHARGE will force all items to be no charge.  Do you wish to proceed?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                //print("NO")
                return
            }
            
            let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("YES")
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }
        
        
        self.contract.chargeType = "\(self.chargeTypePicker.selectedRow(inComponent: 0) + 1)"
        self.chargeTypeTxtField.text = self.chargeTypeArray[self.chargeTypePicker.selectedRow(inComponent: 0)]
        
        self.editsMade = true

    }
    
    
  
    
    
/////////////// Search Delegate Methods   ///////////////////////
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        //print("search edit")
        //print("searchText.count = \(searchText.count)")
        if(searchBar.tag == 1){
            //Customer
            self.tableViewMode = "CUSTOMER"
        }else{
            //Rep
            self.tableViewMode = "REP"
        }
        switch self.tableViewMode{
        case "CUSTOMER":
            if (searchText.count == 0) {
                self.customerResultsTableView.alpha = 0.0
                contract.customerID = ""
                contract.customerName = ""
            }else{
                //print("set cust table alpha to 1")
                self.customerResultsTableView.alpha = 1.0
            }
            break
        default://Rep
            if (searchText.count == 0) {
                self.repResultsTableView.alpha = 0.0
                contract.salesRep = ""
                contract.repName = ""
            }else{
                self.repResultsTableView.alpha = 1.0
            }
            
        }
    
        filterSearchResults()
    }
    
    
    
    func filterSearchResults(){
        
        switch self.tableViewMode{
        case "CUSTOMER":
            //print("CUSTOMER filter")
            customerSearchResults = []
            //print(" text = \(customerSearchBar.text!.lowercased())")
            self.customerSearchResults = self.customerNames.filter({( aCustomer: String ) -> Bool in
                return (aCustomer.lowercased().range(of: customerSearchBar.text!.lowercased(), options:.regularExpression) != nil)})
            self.customerResultsTableView.reloadData()
            break
        default://Rep
            //print("Rep filter")
            repSearchResults = []
            self.repSearchResults = self.appDelegate.salesRepNameArray.filter({( aRep: String ) -> Bool in
                return (aRep.lowercased().range(of: repSearchBar.text!.lowercased(), options:.regularExpression) != nil)})
            self.repResultsTableView.reloadData()
            
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(searchBar.tag == 1){
            self.customerResultsTableView.reloadData()
            
        }else{
            self.repResultsTableView.reloadData()
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y -= 160
                
            }, completion: { finished in
                //print("Napkins opened!")
            })
            
           
            
        }
        
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
        // self.tableViewMode = "TASK"
        
        if(searchBar.tag == 1){
            self.customerResultsTableView.reloadData()
            
        }else{
            
          
            
            if(self.view.frame.origin.y < 0){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.view.frame.origin.y += 160
                    
                    
                }, completion: { finished in
                })
            }
        }
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //print("search btn clicked self.tableViewMode = \(self.tableViewMode)")
        switch self.tableViewMode{
        case "CUSTOMER":
            self.customerResultsTableView.reloadData()
            break
        case "REP":
            self.repResultsTableView.reloadData()
            
            break
        default:
            self.customerResultsTableView.reloadData()
        }
        searchBar.resignFirstResponder()
        
        // self.tableViewMode = "TASK"
        
    }
    
    
    
    
    /////////////// Table Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        switch self.tableViewMode{
        case "CUSTOMER":
            count = self.customerSearchResults.count
            break
        case "REP":
            count = self.repSearchResults.count
            break
        default:
            count = self.customerSearchResults.count
            
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print("cell for row tableViewMode = \(self.tableViewMode)")
        switch self.tableViewMode{
        case "CUSTOMER":
            
            ////print("customer name: \(self.customerNames[indexPath.row])")
            let searchString = self.customerSearchBar.text!.lowercased()
            let cell:CustomerTableViewCell = customerResultsTableView.dequeueReusableCell(withIdentifier: "customerCell") as! CustomerTableViewCell
            
            
            cell.nameLbl.text = self.customerSearchResults[indexPath.row]
            cell.name = self.customerSearchResults[indexPath.row]
            if let i = self.customerNames.index(of: cell.nameLbl.text!) {
                cell.id = self.customerIDs[i]
            } else {
                cell.id = ""
            }
            
            //text highlighting
            let baseString:NSString = cell.name as NSString
            let highlightedText = NSMutableAttributedString(string: cell.name)
            var error: NSError?
            let regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error1 as NSError {
                error = error1
                regex = nil
            }
            if let regexError = error {
                print("Oh no! \(regexError)")
            } else {
                for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                    highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
            }
            cell.nameLbl.attributedText = highlightedText
            
            
            return cell
           // break
        case "REP":
            let searchString = self.repSearchBar.text!.lowercased()
            let cell:CustomerTableViewCell = repResultsTableView.dequeueReusableCell(withIdentifier: "repCell") as! CustomerTableViewCell
            
            cell.nameLbl.text = self.repSearchResults[indexPath.row]
            cell.name = self.repSearchResults[indexPath.row]
            if let i = self.appDelegate.salesRepNameArray.index(of: cell.nameLbl.text!) {
                cell.id = self.self.appDelegate.salesRepIDArray[i]
            } else {
                cell.id = ""
            }
            
            //text highlighting
            let baseString:NSString = cell.name as NSString
            let highlightedText = NSMutableAttributedString(string: cell.name)
            var error: NSError?
            let regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error1 as NSError {
                error = error1
                regex = nil
            }
            if let regexError = error {
                print("Oh no! \(regexError)")
            } else {
                for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                    highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
            }
            cell.nameLbl.attributedText = highlightedText
            
            
            return cell
           // break
            
        default://CUSTOMER
            
            //print("customer name: \(self.customerNames[indexPath.row])")
            let cell:CustomerTableViewCell = customerResultsTableView.dequeueReusableCell(withIdentifier: "customerCell") as! CustomerTableViewCell
            
            return cell
            
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.tableViewMode{
            
        case "CUSTOMER":
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
            contract.customerID = currentCell.id
            contract.customerName = currentCell.name
            
            customerSearchBar.text = currentCell.name
            customerResultsTableView.alpha = 0.0
            customerSearchBar.resignFirstResponder()
            break
        case "REP":
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
            contract.salesRep = currentCell.id
            contract.repName = currentCell.name
            
            repSearchBar.text = currentCell.name
            repResultsTableView.alpha = 0.0
            repSearchBar.resignFirstResponder()
            
            self.checkForSalesRepSignature()
            
            break
        default:
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
            contract.customerID = currentCell.id
            contract.customerName = currentCell.name
            
            customerSearchBar.text = currentCell.name
            customerResultsTableView.alpha = 0.0
            customerSearchBar.resignFirstResponder()
            break
            
            
            // print("selected customer id = \(self.customerSelectedID)")
            // print("selected rep id = \(self.repSelectedID)")
        }
        editsMade = true
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.tag == 2{
            titleTxtField.reset()
        }
        
        if textField.tag == 3{
           chargeTypeTxtField.reset()
        }
        
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.editsMade = true
    }
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validateFields()->Bool{
        //print("validate fields")
        if titleTxtField.text != ""{
            contract.title = titleTxtField.text!
        }
        //customer check
        if(contract.customerID == ""){
            //print("select a customer")
            
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Contract", _message: "Select a Customer")
            return false
        }
        
        //title check
        if(contract.title == ""){
            //print("Add a Title")
            titleTxtField.error()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Contract", _message: "Provide a Title")
            return false
        }
        
        //charge type check
        if(contract.chargeType == ""){
            //print("select a charge type")
            chargeTypeTxtField.error()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Contract", _message: "Select a Charge Type")
            return false
        }
        
       
        
        
        
        //rep check
        if(contract.salesRep == ""){
            //print("select a sales rep")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Contract", _message: "Select a Sales Rep.")
            return false
        }
        
        
       
        
        
        return true
        
        
    }
    
    
    
    @objc func submit(){
        //print("submit Contract")
       // var newContract:Bool = false
       
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        
        
        
        if(!validateFields()){
            //print("didn't pass validation")
            return
        }
        //validate all fields
        
        contract.notes = self.notesView.text
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        //self.search
        /*
        php params
 
         $contractID = intval($_POST['contractID']);
         $createdBy = intval($_POST['createdBy']);
         $customer = intval($_POST['customer']);
         $salesRep = intval($_POST['salesRep']);
         $terms = intval($_POST['terms']);
         $chargeType = intval($_POST['chargeType']);
         $status = intval($_POST['status']);
         $total = floatval($_POST['total']);
         $notes = $_POST['notes'];
         $repName = $_POST['repName'];
         $customerName = $_POST['customerName'];
         $title = $_POST['title'];
 
        */
        
        
        
        
        var parameters:[String:String] = [:]
        if self.contract.lead != nil{
            parameters = ["contractID": self.contract.ID, "createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), "customer": self.contract.customerID!, "salesRep": self.contract.salesRep,  "chargeType": contract.chargeType , "status": self.contract.status, "total":self.contract.total, "notes":self.contract.notes, "repName":self.contract.repName, "customerName":self.contract.customerName, "title":self.contract.title, "companySigned":self.contract.repSignature,"customerSigned":self.contract.customerSignature,"leadID":self.contract.lead?.ID,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!] as! [String : String]
        }else{
            parameters = ["contractID": self.contract.ID, "createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), "customer": self.contract.customerID!, "salesRep": self.contract.salesRep,  "chargeType": contract.chargeType , "status": self.contract.status, "total":self.contract.total, "notes":self.contract.notes, "repName":self.contract.repName, "customerName":self.contract.customerName, "title":self.contract.title, "companySigned":self.contract.repSignature,"customerSigned":self.contract.customerSignature,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!] as! [String : String]
        }
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/contract.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("contract response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.json = JSON(json)
                    let newContractID = self.json["contractID"].stringValue
                    self.contract.ID = newContractID
                    
                    self.layoutVars.playSaveSound()
                    
                    self.editsMade = false // avoids the back without saving check
                    
                    
                    if(self.title == "New Contract"){
                        
                        _ = self.navigationController?.popViewController(animated: false)

                        
                        if self.leadTaskDelegate != nil{
                           //pop 2 views off the stack (editContract, assignLeadTasks)
                           
                            self.leadTaskDelegate.handleNewContract(_contract:self.contract)
                    
                        }
                    
                        if self.delegate != nil{
                            print("self.delegate.getContracts(_openNewContract: true)")
                            self.delegate.getContracts(_openNewContract: true)

                        }
                        
                    }else if(self.title == "New Customer Contract"){
                        //no delegate method
                    }else{
                        _ = self.navigationController?.popViewController(animated: false)
                        self.editDelegate.updateContract(_contract: self.contract)
                    }
                    
                }
                //print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
    }
    
    
    @objc func goBack(){
        if(self.editsMade == true){
            //print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                //print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                _ = self.navigationController?.popViewController(animated: false)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
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
    
    
    
    
    
    func checkForSalesRepSignature(){
        //print("check for employee signature")
      
        self.contract.repSignature = "0"
        var hasSignature:Bool = false
        
        // take rep ID and loop through Sales Rep Array and get signature value
        //appDelegate.employeeArray
        for rep in appDelegate.salesRepArray {
            //print("looping through sales rep array")
                if self.contract.salesRep == rep.ID{
                    if rep.hasSignature == true {
                        hasSignature = true
                        self.contract.repSignature = "1"
                        //print("hasSignature = true")

                    }
                
            }
        }
        
        
        if hasSignature == false{
            
            if appDelegate.loggedInEmployee?.ID == contract.salesRep{
                //your contract, you = the rep
                
                let alertController = UIAlertController(title: "No Sales Rep Signature", message: "Do you want to add your signature now?", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    //NO  proceed with get contract
                    // self.getContract()
                    self.contract.repSignature = "0"
                }
                let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    //YES  go to signature page
                    
                    let signatureViewController:SignatureViewController = SignatureViewController(_employee: self.appDelegate.loggedInEmployee!, _contract: self.contract)
                    signatureViewController.delegate = self
                    self.navigationController?.pushViewController(signatureViewController, animated: false )
                                    
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                layoutVars.getTopController().present(alertController, animated: true)
                
            }else{
                //print("this is not your contract")
                
                let alertController = UIAlertController(title: "Not Your Contract", message: "You are not the sales rep assigned to this contract.  You may want to change it and provide your signature.", preferredStyle: UIAlertController.Style.alert)
                
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    //print("OK")
                }
                
                self.contract.repSignature = "0"
                
                alertController.addAction(okAction)
                layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            }
            
        }
            
    }
    
    
    
    
    //edit delegates
    
    func updateContract(_contract: Contract2){
        //print("update Contract")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        editsMade = true
        self.contract = _contract
        
        
        
        var parameters:[String:String]
        parameters = [
            "contractID":self.contract.ID,
            "createdBy":self.contract.createdBy,
            "customer":self.contract.customerID!,
            "salesRep":self.contract.salesRep!,
            "chargeType":self.contract.chargeType!,
            "status":self.contract.status,
            "total":self.contract.total!,
            "notes":self.contract.notes!,
            "repName":self.contract.repName!,
            "customerName":self.contract.customerName!,
            "title":self.contract.title,
            "companySigned":self.contract.repSignature!,
            "customerSigned":self.contract.customerSignature!,
            "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,
            "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!
            
        ]
        
        //print("parameters = \(parameters)")
        
        
        
        self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/contract.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            self.layoutVars.playSaveSound()
            self.layoutViews()
        }
        
    }
    
    
    
    func updateContract(_contract: Contract2, _status:String){
        //print("update Contract")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        editsMade = true
        self.contract = _contract
        
        
        
        var parameters:[String:String]
        parameters = [
            "contractID":self.contract.ID,
            "createdBy":self.contract.createdBy,
            "customer":self.contract.customerID!,
            "salesRep":self.contract.salesRep!,
            "chargeType":self.contract.chargeType!,
            "status":self.contract.status,
            "total":self.contract.total!,
            "notes":self.contract.notes!,
            "repName":self.contract.repName!,
            "customerName":self.contract.customerName!,
            "title":self.contract.title,
            "companySigned":self.contract.repSignature!,
            "customerSigned":self.contract.customerSignature!,
            "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,
            "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!
            
        ]
        
        //print("parameters = \(parameters)")
        
        
        
        self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/contract.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            self.layoutVars.playSaveSound()
            
            self.layoutViews()
        }
        setStatus(status: _status)
    }
    
    func updateContract(_contractItem: ContractItem2){
        //print("updateContract Item")
       
    }
    func suggestStatusChange(_emailCount:Int) {
        //print("suggestStatusChange")
    }
    

    func updateTable(_points:Int){
        //print("updateTable")
    }
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
            getPickerInfo()
       }
    
}
