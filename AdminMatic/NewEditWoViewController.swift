//
//  NewEditWoViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/22/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
 

class NewEditWoViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate, NoInternetDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    
    var lead:Lead2!
    var taskArray:[Task2]!
    var contract:Contract2!
    var wo:WorkOrder2!
    
    let dateFormatter = DateFormatter()
    var safeContainer:UIView!
    var submitButton:UIBarButtonItem!
    
    var delegate:ScheduleDelegate!
    var editDelegate:WoDelegate!
    var leadTaskDelegate:LeadTaskDelegate!
    var editContractDelegate:EditContractDelegate!
    
    //customer search
    var customerLbl:GreyLabel!
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
    
    
    //invoice type
    var invoiceTypeLbl:GreyLabel!
    var invoiceTypeTxtField:PaddedTextField!
    var invoiceTypePicker: Picker!
    var invoiceTypeArray = ["Upon Completion", "Batch", "No Invoice"]
    
    //schedule type
    var scheduleTypeLbl:GreyLabel!
    var scheduleTypeTxtField:PaddedTextField!
    var scheduleTypePicker: Picker!
    var scheduleTypeArray = ["ASAP", "Week Of", "Firm", "Recurring", "UnScheduled"]
    
    //schedule options
    var scheduleOptionsBtn:Button = Button(titleText: "Options")
    
    
    //department
    var departmentLbl:GreyLabel!
    var departmentTxtField:PaddedTextField!
    var departmentPicker: Picker!
    
    //crew
    var crewLbl:GreyLabel!
    var crewTxtField:PaddedTextField!
    var crewPicker: Picker!
    
    
    //rep search
    var repLbl:GreyLabel!
    var repSearchBar:UISearchBar = UISearchBar()
    var repResultsTableView:TableView = TableView()
    var repSearchResults:[String] = []
    
    
    //description textview
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
        self.wo = WorkOrder2(_ID: "0", _title:"", _status: "1", _type: "", _progress: "", _totalPrice: "", _totalCost: "", _totalPriceRaw: "", _totalCostRaw: "", _profitValue: "", _percentValue: "")
    }
    
    //init for edit
    init(_wo:WorkOrder2){
        super.init(nibName:nil,bundle:nil)
        print("wo edit init \(String(describing: _wo.ID))")
        print("wo title \(String(describing: _wo.title))")
        //print("wo custName \(_wo.customerName)")
        //print("wo rep \(_wo.rep)")
        //print("wo invoice \(_wo.invoiceType)")
       //
        self.wo = _wo
        
    }
    
    //new from customer view
    init(_customer:Customer2){
        super.init(nibName:nil,bundle:nil)
        print("wo edit init from customer \(_customer.sysname)")
        self.wo = WorkOrder2(_ID: "0", _title:"", _status: "1", _type: "", _progress: "0", _totalPrice: "0", _totalCost: "0", _totalPriceRaw: "0", _totalCostRaw: "0", _profitValue: "0", _percentValue: "0")
        self.wo.customer =  _customer.ID
        self.wo.custName =  _customer.sysname
        if _customer.address != nil{
            self.wo.custAddress = _customer.address!
        }else{
            self.wo.custAddress = "No Address"
        }
    }
    
    //new from lead
    init(_lead:Lead2,_tasks: [Task2]){
        super.init(nibName:nil,bundle:nil)
        
        print("new work order from lead init")
        
        self.lead = _lead
        self.taskArray = _tasks
        
        self.wo = WorkOrder2(_ID: "0", _title:"", _status: "1", _type: "", _progress: "0", _totalPrice: "0", _totalCost: "0", _totalPriceRaw: "0", _totalCostRaw: "0", _profitValue: "0", _percentValue: "0")
        
       let customer = Customer2(_ID: self.lead.customerID!, _sysname: self.lead.customerName!)
        self.wo.customer = customer.ID
        self.wo.custName = customer.sysname
        if customer.address != nil{
            self.wo.custAddress = customer.address!
        }else{
            self.wo.custAddress = "No Address"
        }
    
        self.wo.rep = self.lead.rep
        self.wo.repName = self.lead.repName
    }
    
    
    //new from contract
    init(_contract:Contract2, _wo:WorkOrder2){
        super.init(nibName:nil,bundle:nil)
        print("new work order from contract init")
        self.contract = _contract
        //print("wo title \(_wo.title)")
        if _wo.custName != nil{
            print("wo custName \(_wo.custName!)")
        }
        self.wo = _wo
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
        backButton.addTarget(self, action: #selector(NewEditWoViewController.goBack), for: UIControl.Event.touchUpInside)
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
        print("get picker info")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        indicator = SDevIndicator.generate(self.view)!
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
       //Get cust list
              var parameters:[String:String]
              parameters = ["sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!]
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
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
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
                print("Error deserializing JSON: \(error)")
            }
        }
        
        
        
    }
    
    
    func layoutViews(){
        //print("layout views")
        
        
        if(self.wo == nil){
            title =  "New Work Order"
            submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditWoViewController.submit))
            
        }else{
            if(self.wo.ID == "0"){
                //coming from customer page
                title =  "New Work Order"
                submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditWoViewController.submit))
            }else{
                title =  "Edit Work Order #" + self.wo.ID
                submitButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(NewEditWoViewController.submit))
            }
            
        }
        navigationItem.rightBarButtonItem = submitButton
        
       
        
        //set container to safe bounds of view
        safeContainer = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        //customer
        self.customerLbl = GreyLabel()
        self.customerLbl.text = "Customer:"
        safeContainer.addSubview(customerLbl)
        
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
        
        if self.wo.customer != nil{
            if self.wo.customer != "0"{
                self.customerSearchBar.text = self.wo.custName!
            }
        }
        
        let custToolBar = UIToolbar()
        custToolBar.barStyle = UIBarStyle.default
        custToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        custToolBar.sizeToFit()
        let closeCustButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelCustInput))
        
        custToolBar.setItems([closeCustButton], animated: false)
        custToolBar.isUserInteractionEnabled = true
        customerSearchBar.inputAccessoryView = custToolBar
        
        if(self.customerIDs.count == 0){
            customerSearchBar.isUserInteractionEnabled = false
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
        
        
        if(wo.title != ""){
            self.titleTxtField = PaddedTextField()
            self.titleTxtField.text = wo.title
        }else{
            
            self.titleTxtField = PaddedTextField(placeholder: "Title...")
        }
        
        self.titleTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.titleTxtField.delegate = self
        self.titleTxtField.autocapitalizationType = .words
        self.titleTxtField.returnKeyType = .done
        safeContainer.addSubview(self.titleTxtField)
        
        let titleToolBar = UIToolbar()
        titleToolBar.barStyle = UIBarStyle.default
        titleToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        titleToolBar.sizeToFit()
        let closeTitleButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelTitleInput))
        
        titleToolBar.setItems([closeTitleButton], animated: false)
        titleToolBar.isUserInteractionEnabled = true
        self.titleTxtField.inputAccessoryView = titleToolBar
        
        
        //charge type
        self.chargeTypeLbl = GreyLabel()
        self.chargeTypeLbl.text = "Charge Type:"
        safeContainer.addSubview(chargeTypeLbl)
        
        self.chargeTypePicker = Picker()
        self.chargeTypePicker.delegate = self
        self.chargeTypePicker.dataSource = self
        self.chargeTypePicker.tag = 1
        
        
        self.chargeTypeTxtField = PaddedTextField(placeholder: "Charge Type...")
        self.chargeTypeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.chargeTypeTxtField.delegate = self
        self.chargeTypeTxtField.inputView = chargeTypePicker
        safeContainer.addSubview(self.chargeTypeTxtField)
        
        
        let chargeTypeToolBar = UIToolbar()
        chargeTypeToolBar.barStyle = UIBarStyle.default
        chargeTypeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        chargeTypeToolBar.sizeToFit()
        let closeChargeTypeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelChargeTypeInput))
        
        let setChargeTypeButton = BarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.handleChargeTypeChange))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        chargeTypeToolBar.setItems([closeChargeTypeButton, spaceButton, setChargeTypeButton], animated: false)
        chargeTypeToolBar.isUserInteractionEnabled = true
        chargeTypeTxtField.inputAccessoryView = chargeTypeToolBar
        
        
        if(wo.charge != nil){
            chargeTypeTxtField.text = chargeTypeArray[Int(wo.charge!)! - 1]
            self.chargeTypePicker.selectRow(Int(self.wo.charge!)! - 1, inComponent: 0, animated: false)
        }
        
        //invoice type
        self.invoiceTypeLbl = GreyLabel()
        self.invoiceTypeLbl.text = "Invoice Type:"
        safeContainer.addSubview(invoiceTypeLbl)
        
        self.invoiceTypePicker = Picker()
        self.invoiceTypePicker.delegate = self
        self.invoiceTypePicker.dataSource = self
        self.invoiceTypePicker.tag = 2
        
        
        self.invoiceTypeTxtField = PaddedTextField(placeholder: "Invoice Type...")
        self.invoiceTypeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.invoiceTypeTxtField.delegate = self
        self.invoiceTypeTxtField.tag = 3
        self.invoiceTypeTxtField.inputView = invoiceTypePicker
        safeContainer.addSubview(self.invoiceTypeTxtField)
        
        
        let invoiceTypeToolBar = UIToolbar()
        invoiceTypeToolBar.barStyle = UIBarStyle.default
        invoiceTypeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        invoiceTypeToolBar.sizeToFit()
        let closeInvoiceTypeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelInvoiceTypeInput))
        
        let setInvoiceTypeButton = BarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.handleInvoiceTypeChange))
        invoiceTypeToolBar.setItems([closeInvoiceTypeButton, spaceButton, setInvoiceTypeButton], animated: false)
        invoiceTypeToolBar.isUserInteractionEnabled = true
        invoiceTypeTxtField.inputAccessoryView = invoiceTypeToolBar
        
        
        if(wo.invoiceType != nil){
            invoiceTypeTxtField.text = invoiceTypeArray[Int(wo.invoiceType!)! - 1]
            self.invoiceTypePicker.selectRow(Int(self.wo.invoiceType!)! - 1, inComponent: 0, animated: false)
        }
        
        //schedule type
        self.scheduleTypeLbl = GreyLabel()
        self.scheduleTypeLbl.text = "Schedule Type:"
        safeContainer.addSubview(scheduleTypeLbl)
        
        self.scheduleTypePicker = Picker()
        self.scheduleTypePicker.delegate = self
        self.scheduleTypePicker.dataSource = self
        self.scheduleTypePicker.tag = 3
        
        
        self.scheduleTypeTxtField = PaddedTextField(placeholder: "Schedule Type...")
        self.scheduleTypeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.scheduleTypeTxtField.delegate = self
        self.scheduleTypeTxtField.inputView = scheduleTypePicker
        safeContainer.addSubview(self.scheduleTypeTxtField)
        
        
        let scheduleTypeToolBar = UIToolbar()
        scheduleTypeToolBar.barStyle = UIBarStyle.default
        scheduleTypeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        scheduleTypeToolBar.sizeToFit()
        let closeScheduleTypeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelScheduleTypeInput))
        
        let setScheduleTypeButton = BarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.handleScheduleTypeChange))
        scheduleTypeToolBar.setItems([closeScheduleTypeButton, spaceButton, setScheduleTypeButton], animated: false)
        scheduleTypeToolBar.isUserInteractionEnabled = true
        scheduleTypeTxtField.inputAccessoryView = scheduleTypeToolBar
        
        //If new, temporarily set schedule types to UnScheduled
        if wo.ID == "0" || wo.scheduleType == nil{
            wo.scheduleType = "5"
            
        }
        
        scheduleTypeTxtField.text = scheduleTypeArray[Int(wo.scheduleType!)! - 1]
        scheduleTypeTxtField.isEnabled = false
        
        self.scheduleOptionsBtn.backgroundColor = UIColor.white
        self.scheduleOptionsBtn.layer.borderWidth = 1
        self.scheduleOptionsBtn.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.scheduleOptionsBtn.layer.cornerRadius = 4.0
        //self.scheduleOptionsBtn.titleLabel?.textColor = UIColor.black
        self.scheduleOptionsBtn.setTitleColor(UIColor.black, for: .normal)
        
        self.scheduleOptionsBtn.addTarget(self, action: #selector(NewEditWoViewController.scheduleOptions), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.scheduleOptionsBtn)
        
        //temporarily disable options btn
        self.scheduleOptionsBtn.isEnabled = false
        
        //department
        self.departmentLbl = GreyLabel()
        self.departmentLbl.text = "Department:"
        safeContainer.addSubview(departmentLbl)
        
        self.departmentPicker = Picker()
        self.departmentPicker.delegate = self
        self.departmentPicker.dataSource = self
        self.departmentPicker.tag = 4
        
        
        self.departmentTxtField = PaddedTextField(placeholder: "Department...")
        self.departmentTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.departmentTxtField.delegate = self
        self.departmentTxtField.inputView = departmentPicker
        safeContainer.addSubview(self.departmentTxtField)
        
        
        let departmentToolBar = UIToolbar()
        departmentToolBar.barStyle = UIBarStyle.default
        departmentToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        departmentToolBar.sizeToFit()
        let closeDepartmentButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelDepartmentInput))
        
        let setDepartmentButton = BarButtonItem(title: "Set Dept.", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.handleDepartmentChange))
        departmentToolBar.setItems([closeDepartmentButton, spaceButton, setDepartmentButton], animated: false)
        departmentToolBar.isUserInteractionEnabled = true
        departmentTxtField.inputAccessoryView = departmentToolBar
        
        
        if(wo.department != ""){
            for dept in 0 ..< self.appDelegate.departments.count {
                if self.appDelegate.departments[dept].ID == wo.department{
                    departmentTxtField.text = self.appDelegate.departments[dept].name
                    self.departmentPicker.selectRow(dept, inComponent: 0, animated: false)
                }
            }
        }
        
        //crew
        self.crewLbl = GreyLabel()
        self.crewLbl.text = "Crew:"
        safeContainer.addSubview(crewLbl)
        
        self.crewPicker = Picker()
        self.crewPicker.delegate = self
        self.crewPicker.dataSource = self
        self.crewPicker.tag = 5
        
        self.crewTxtField = PaddedTextField(placeholder: "Crew...")
        self.crewTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.crewTxtField.delegate = self
        self.crewTxtField.inputView = crewPicker
        safeContainer.addSubview(self.crewTxtField)
        
        let crewToolBar = UIToolbar()
        crewToolBar.barStyle = UIBarStyle.default
        crewToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        crewToolBar.sizeToFit()
        let closeCrewButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelCrewInput))
        
        let setCrewButton = BarButtonItem(title: "Set Crew", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.handleCrewChange))
        crewToolBar.setItems([closeCrewButton, spaceButton, setCrewButton], animated: false)
        crewToolBar.isUserInteractionEnabled = true
        crewTxtField.inputAccessoryView = crewToolBar
        
        if(wo.crew != ""){
            for crew in 0 ..< self.appDelegate.crews.count {
                if self.appDelegate.crews[crew].ID == wo.crew{
                    crewTxtField.text = self.appDelegate.crews[crew].name
                    self.crewPicker.selectRow(crew, inComponent: 0, animated: false)
                }
            }
        }
        
        //sales rep
        self.repLbl = GreyLabel()
        self.repLbl.text = "Sales Rep:"
        
        safeContainer.addSubview(repLbl)
        
        repSearchBar.placeholder = "Sales Rep..."
        repSearchBar.translatesAutoresizingMaskIntoConstraints = false
        
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
        let closeRepButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelRepInput))
        
        repToolBar.setItems([closeRepButton], animated: false)
        repToolBar.isUserInteractionEnabled = true
        repSearchBar.inputAccessoryView = repToolBar
        
        if(self.appDelegate.salesRepIDArray.count == 0){
            repSearchBar.isUserInteractionEnabled = false
        }
        if(wo.rep != ""){
            repSearchBar.text = wo.repName
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
        self.notesView.text = self.wo.notes
        self.notesView.font = layoutVars.smallFont
        self.notesView.isEditable = true
        self.notesView.delegate = self
        self.notesView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.notesView)
        
        let notesToolBar = UIToolbar()
        notesToolBar.barStyle = UIBarStyle.default
        notesToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        notesToolBar.sizeToFit()
        let closeNotesButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditWoViewController.cancelNotesInput))
        
        notesToolBar.setItems([closeNotesButton], animated: false)
        notesToolBar.isUserInteractionEnabled = true
        self.notesView.inputAccessoryView = notesToolBar
        
        safeContainer.addSubview(self.customerResultsTableView)
        safeContainer.addSubview(self.repResultsTableView)
        
        /////////  Auto Layout   //////////////////////////////////////
        
       let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150, "halfWidth": layoutVars.halfWidth - 8] as [String:Any]
        
        //auto layout group
        let dictionary = [
            "customerLbl":self.customerLbl,
            "customerSearchBar":self.customerSearchBar,
            "customerTable":self.customerResultsTableView,
            "titleLbl":self.titleLbl,
            "titleTxtField":self.titleTxtField,
            "chargeTypeLbl":self.chargeTypeLbl,
            "chargeTypeTxtField":self.chargeTypeTxtField,
            "invoiceTypeLbl":self.invoiceTypeLbl,
            "invoiceTypeTxtField":self.invoiceTypeTxtField,
            "scheduleTypeLbl":self.scheduleTypeLbl,
            "scheduleTypeTxtField":self.scheduleTypeTxtField,
            "scheduleOptions":self.scheduleOptionsBtn,
            "departmentLbl":self.departmentLbl,
            "departmentTxtField":self.departmentTxtField,
            "crewLbl":self.crewLbl,
            "crewTxtField":self.crewTxtField,
            "repLbl":self.repLbl,
            "repSearchBar":self.repSearchBar,
            "repTable":self.repResultsTableView,
            "notesLbl":self.notesLbl,
            "notesView":self.notesView
            ] as [String:AnyObject]
        
        
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[customerLbl(80)]-[customerSearchBar]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[customerTable]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLbl]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleTxtField]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chargeTypeLbl(halfWidth)]-[invoiceTypeLbl]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chargeTypeTxtField(halfWidth)]-[invoiceTypeTxtField]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scheduleTypeLbl(halfWidth)]", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scheduleTypeTxtField(halfWidth)]-[scheduleOptions]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[departmentLbl(halfWidth)]-[crewLbl]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[departmentTxtField(halfWidth)]-[crewTxtField]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[repLbl(80)]-[repSearchBar]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[repTable]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notesLbl]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notesView]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[customerLbl(40)]-[titleLbl(30)][titleTxtField(40)]-[chargeTypeLbl(30)][chargeTypeTxtField(40)]-[scheduleTypeLbl(30)][scheduleTypeTxtField(40)]-[departmentLbl(30)][departmentTxtField(40)]-10-[repLbl(40)]-[notesLbl(30)][notesView]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[customerSearchBar(40)]-[titleLbl(30)][titleTxtField(40)]-[invoiceTypeLbl(30)][invoiceTypeTxtField(40)]-[scheduleTypeLbl(30)][scheduleOptions(40)]-[crewLbl(30)][crewTxtField(40)]-10-[repSearchBar(40)]-[notesLbl(30)][notesView]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[customerSearchBar(40)][customerTable]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[customerSearchBar(40)]-[titleLbl(30)][titleTxtField(40)]-[invoiceTypeLbl(30)][invoiceTypeTxtField(40)]-[scheduleTypeLbl(30)][scheduleOptions(40)]-[crewLbl(30)]-[crewTxtField(40)]-10-[repSearchBar(40)][repTable]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
    }
    
    @objc func cancelCustInput(){
        print("Cancel Cust Input")
        self.customerSearchBar.resignFirstResponder()
        self.customerResultsTableView.alpha = 0.0
    }
    
    @objc func cancelChargeTypeInput(){
        print("Cancel Charge Type Input")
        self.chargeTypeTxtField.resignFirstResponder()
    }
    
    @objc func cancelInvoiceTypeInput(){
        print("Cancel Invoice Type Input")
        self.invoiceTypeTxtField.resignFirstResponder()
    }
    
    @objc func cancelScheduleTypeInput(){
        print("Cancel Schedule Type Input")
        self.scheduleTypeTxtField.resignFirstResponder()
    }
    
    @objc func cancelDepartmentInput(){
        print("Cancel Department Input")
        self.departmentTxtField.resignFirstResponder()
    }
    
    @objc func cancelCrewInput(){
        print("Cancel Crew Input")
        self.crewTxtField.resignFirstResponder()
    }
    
    
    @objc func cancelRepInput(){
        print("Cancel Rep Input")
        self.repSearchBar.resignFirstResponder()
        self.repResultsTableView.alpha = 0.0
        if(self.view.frame.origin.y < 0){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y = 0
            }, completion: { finished in
            })
        }
    }
    
    @objc func cancelTitleInput(){
        print("Cancel Title Input")
        self.titleTxtField.resignFirstResponder()
    }
    
    @objc func cancelNotesInput(){
        print("Cancel Notes Input")
        self.notesView.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField.tag == 3{
                invoiceTypeTxtField.reset()
            }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editsMade = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {        print("textFieldDidBeginEditing")
       
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textFieldDidEndEditing")
        editsMade = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    //picker methods
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        // shows first 3 status options, not cancel or waiting
        print("pickerview tag: \(pickerView.tag)")
        var count:Int = 0
        
        
        switch pickerView.tag {
        case 1:
            count = self.chargeTypeArray.count
            break
        case 2:
            count = self.invoiceTypeArray.count
            break
        case 3:
            count = self.scheduleTypeArray.count
            break
        case 4:
            count = self.appDelegate.departments.count
            break
        case 5:
            count = self.appDelegate.crews.count
            break
        default:
            count = 0
        }
        return count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title:String = ""
        switch pickerView.tag {
        case 1:
            title = self.chargeTypeArray[row]
            break
        case 2:
            title = self.invoiceTypeArray[row]
            break
        case 3:
            title = self.scheduleTypeArray[row]
            break
        case 4:
            title = self.appDelegate.departments[row].name
            print("row title = \(title )")
            break
        case 5:
            title = self.appDelegate.crews[row].name
            print("row title = \(title )")
            break
        default:
            title = ""
        }
        
        return title
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        /*
            1 = charge
            2 = invoice
            3 = schedule
            4 = department
            5 = crew
        */
        
        print("pickerview tag: \(pickerView.tag)")
        
        switch pickerView.tag {
        case 1:
            wo.charge = "\(row + 1)"
            break
        case 2:
            wo.invoiceType = "\(row + 1)"
            break
        case 3:
            wo.scheduleType = "\(row + 1)"
            break
        case 4:
            wo.department = self.appDelegate.departments[row].ID
            break
        case 5:
            wo.crew = self.appDelegate.crews[row].ID
            break
        default:
            wo.charge = "\(row + 1)"
        }
    }
    
    
    @objc func handleChargeTypeChange(){
        print("handle chargeType change")
        self.chargeTypeTxtField.resignFirstResponder()
        wo.charge = "\(self.chargeTypePicker.selectedRow(inComponent: 0) + 1)"
        self.chargeTypeTxtField.text = self.chargeTypeArray[self.chargeTypePicker.selectedRow(inComponent: 0)]
        editsMade = true
    }
    
    
    @objc func handleInvoiceTypeChange(){
        print("handle invoiceType change")
        self.invoiceTypeTxtField.resignFirstResponder()
        wo.invoiceType = "\(self.invoiceTypePicker.selectedRow(inComponent: 0) + 1)"
        self.invoiceTypeTxtField.text = self.invoiceTypeArray[self.invoiceTypePicker.selectedRow(inComponent: 0)]
        editsMade = true
    }
    
    @objc func handleScheduleTypeChange(){
        print("handle scheduleType change")
        self.scheduleTypeTxtField.resignFirstResponder()
        wo.scheduleType = "\(self.scheduleTypePicker.selectedRow(inComponent: 0) + 1)"
        self.scheduleTypeTxtField.text = self.scheduleTypeArray[self.scheduleTypePicker.selectedRow(inComponent: 0)]
        editsMade = true
    }
    
    
    @objc func scheduleOptions(){
        print("schedule options")
    }
    
    @objc func handleDepartmentChange(){
        print("handle department change")
        self.departmentTxtField.resignFirstResponder()
        wo.department = self.appDelegate.departments[self.departmentPicker.selectedRow(inComponent: 0)].ID
        self.departmentTxtField.text = self.appDelegate.departments[self.departmentPicker.selectedRow(inComponent: 0)].name
        editsMade = true
    }
    
    @objc func handleCrewChange(){
        print("handle crew change")
        self.crewTxtField.resignFirstResponder()
        wo.crew = self.appDelegate.crews[self.crewPicker.selectedRow(inComponent: 0)].ID
        wo.crewName = self.appDelegate.crews[self.crewPicker.selectedRow(inComponent: 0)].name
        self.crewTxtField.text = self.appDelegate.crews[self.crewPicker.selectedRow(inComponent: 0)].name
        editsMade = true
    }

    
    /////////////// Search Delegate Methods   ///////////////////////
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        print("search edit")
        print("searchText.count = \(searchText.count)")
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
                wo.customer = nil
            }else{
                print("set cust table alpha to 1")
                self.customerResultsTableView.alpha = 1.0
            }
            break
        default://Rep
            if (searchText.count == 0) {
                self.repResultsTableView.alpha = 0.0
                wo.rep = ""
                wo.repName = ""
            }else{
                self.repResultsTableView.alpha = 1.0
            }
        }
        filterSearchResults()
    }
    

    func filterSearchResults(){
        switch self.tableViewMode{
        case "CUSTOMER":
            print("CUSTOMER filter")
            customerSearchResults = []
            print(" text = \(customerSearchBar.text!.lowercased())")
            self.customerSearchResults = self.customerNames.filter({( aCustomer: String ) -> Bool in
                return (aCustomer.lowercased().range(of: customerSearchBar.text!.lowercased(), options:.regularExpression) != nil)})
            self.customerResultsTableView.reloadData()
            break
        default://Rep
            print("Rep filter")
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
                self.view.frame.origin.y -= searchBar.frame.origin.y
            }, completion: { finished in
                print("Napkins opened!")
            })
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
        if(searchBar.tag == 1){
            self.customerResultsTableView.reloadData()
        }else{
            if(self.view.frame.origin.y < 0){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.view.frame.origin.y = 0
                }, completion: { finished in
                })
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search btn clicked self.tableViewMode = \(self.tableViewMode)")
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
        print("cell for row tableViewMode = \(self.tableViewMode)")
        switch self.tableViewMode{
        case "CUSTOMER":
            
            //print("customer name: \(self.customerNames[indexPath.row])")
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
            
            print("currentCell.id = \(String(describing: currentCell.id))")
            print("currentCell.name = \(String(describing: currentCell.name))")
            //print("currentCell.address = \(String(describing: currentCell.address))")
            
            
            wo.customer = currentCell.id
            wo.custName = currentCell.name
            
            customerSearchBar.text = currentCell.name
            customerResultsTableView.alpha = 0.0
            customerSearchBar.resignFirstResponder()
            break
        case "REP":
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
            wo.rep = currentCell.id
            wo.repName = currentCell.name
            
            repSearchBar.text = currentCell.name
            repResultsTableView.alpha = 0.0
            repSearchBar.resignFirstResponder()
            break
        default:
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
          
            wo.customer = currentCell.id
            wo.custName = currentCell.name
            
            customerSearchBar.text = currentCell.name
            customerResultsTableView.alpha = 0.0
            customerSearchBar.resignFirstResponder()
            break
            
        }
        editsMade = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validateFields()->Bool{
        print("validate fields")
        if titleTxtField.text != ""{
            wo.title = titleTxtField.text!
        }
        //customer check
        if wo.customer == nil{
            print("select a customer")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Work Order", _message: "Select a Customer")
            return false
        }
        
        //charge type check
        if wo.charge == nil{
            print("select a charge type")
            self.chargeTypeTxtField.error()
            
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Work Order", _message: "Select a Charge Type")
            return false
        }
        
        //invoice type check
        if wo.invoiceType == nil{
            self.invoiceTypeTxtField.error()
            print("select a invoice type")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Work Order", _message: "Select a Invoice Type")
            return false
        }
        
        //schedule type check
        if wo.scheduleType == nil{
            print("select a schedule type")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Work Order", _message: "Select a Schedule Type")
            return false
        }
        
        //rep check
        if self.repSearchBar.text == ""{
            print("select a sales rep")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Work Order", _message: "Select a Sales Rep.")
            return false
        }
        
        //title check
        if self.titleTxtField.text == ""{
            print("Add a Title")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Work Order", _message: "Provide a Title")
            return false
        }
        
        return true
    }
    
    
    @objc func submit(){
        print("submit Work Order")
        
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        
        if(!validateFields()){
            print("didn't pass validation")
            return
        }
        //validate all fields
        
        wo.notes = self.notesView.text
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        
        var contractID:String
        if self.contract != nil {
            contractID = self.contract.ID
        }else{
            contractID = "0"
        }
        
        var leadID:String
        if self.lead != nil {
            leadID = self.lead.ID
        }else{
            leadID = "0"
        }
        
        var deptString:String
        if self.wo.department != nil{
            deptString = self.wo.department!
        }else{
            deptString = ""
        }
        
        var crewString:String
        if self.wo.crew != nil{
            crewString = self.wo.crew!
        }else{
            crewString = ""
        }
        
        var crewNameString:String
        if self.wo.crewName != nil{
            crewNameString = self.wo.crewName!
        }else{
            crewNameString = ""
        }
        
        
       
        let parameters:[String:String]
        parameters = ["woID": wo.ID,"charge": wo.charge!, "customer": self.wo.customer,  "notes":self.wo.notes, "salesRep": self.wo.rep!, "leadID":leadID, "contractID":contractID, "createdBy": self.appDelegate.loggedInEmployee?.ID, "createdByName": self.appDelegate.loggedInEmployee?.name,     "title":self.wo.title, "crew":crewString, "crewName":crewNameString, "departmentID":deptString, "invoice":self.wo.invoiceType, "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!] as! [String : String]
        
        print("parameters = \(parameters)")
        
        
        if self.wo.ID == "0"{
            //NEW
            layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/new/workOrder.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("work order response = \(response)")
                }
                .responseJSON(){
                    response in
                    
                    do{
                        //created the json decoder
                        
                        let json = response.data
                        let decoder = JSONDecoder()
                        let parsedData = try decoder.decode(WorkOrder2.self, from: json!)
                        print("parsedData = \(parsedData)")
                        self.wo = parsedData
                        self.layoutVars.playSaveSound()
                        self.editsMade = false // avoids the back without saving check
                        if(self.title == "New Work Order"){
                            if self.leadTaskDelegate != nil{
                                self.leadTaskDelegate.handleNewWorkOrder(_workOrder: self.wo)
                                _ = self.navigationController?.popViewController(animated: false)
                                return
                            }
                            
                            
                            if self.delegate != nil{
                                self.delegate.updateSchedule()
                            }
                            self.goBack()
                        }else if(self.title == "New Customer Work Order"){
                            //no delegate method
                        }else{
                            self.goBack()
                            if self.editDelegate != nil{
                                self.editDelegate.refreshWo()
                            }
                        }
                    }catch let err{
                        print(err)
                    }

                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
            }
        }else{
            //UPDATE
            layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/workOrder.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("work order response = \(response)")
                }
                .responseJSON(){
                    response in
                    
                    
                    do{
                        //created the json decoder
                        
                        self.layoutVars.playSaveSound()
                        
                        self.editsMade = false // avoids the back without saving check
                        
                        if self.editContractDelegate != nil{
                          
                            print("editContractDelegate")
                            _ = self.navigationController?.popViewController(animated: false)
                            self.editContractDelegate.updateContract(_contract: self.contract)
                            return
                        }
                        
                        self.goBack()
                        
                    }catch let err{
                        print(err)
                    }

                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
            }
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
    
    func updateTable(_points:Int){
        print("updateTable")
    }
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
        getPickerInfo()
       }
    
}
