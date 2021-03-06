//
//  NewEditLeadViewController.swift
//  AdminMatic2
//
//  Created by Nick on 11/15/17.
//  Copyright © 2017 Nick. All rights reserved.
//
 
//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class NewEditLeadViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate, NoInternetDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    
    
    var lead:Lead2!
    var submitButton:UIBarButtonItem!
    var delegate:LeadListDelegate!
    var editDelegate:EditLeadDelegate!
    
    
    var tableViewMode:String = ""
    
    var statusIcon:UIImageView = UIImageView()
    var statusTxtField:PaddedTextField!
    var statusPicker: Picker!
    var statusArray = ["Not Started", "In Progress","Done","Cancel","Waiting"]

    //customer search
    var customerSearchBar:UISearchBar = UISearchBar()
    var customerResultsTableView:TableView = TableView()
    var customerSearchResults:[String] = []
    
    var customerIDs = [String]()
    var customerNames = [String]()
    
    //schedule type
    var scheduleTypeLbl:GreyLabel!
    var scheduleTypeTxtField:PaddedTextField!
    var scheduleTypePicker: Picker!
    var scheduleTypeArray = ["ASAP (No Appointment)","FIRM (Appointment)"] 
   
    
    let dateFormatter = DateFormatter()
    let dateFormatterDB = DateFormatter()
    let timeFormatterDB = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var aptDate:String = ""
    var aptTime:String = ""
    

    var aptLbl:GreyLabel!
    var aptDateTxtField: PaddedTextField!
    var aptDatePickerView :DatePicker!
    var aptTimeTxtField: PaddedTextField!
    var aptTimePickerView :DatePicker!
    
    //deadline switch and date picker
    var deadlineLbl:GreyLabel!
    var deadlineTxtField: PaddedTextField!
    var deadlinePickerView :DatePicker!
    
    //urgent switch
    var urgentLbl:GreyLabel!
    var urgentSwitch:UISwitch = UISwitch()
    
    
    //rep search
    var repLbl:GreyLabel!
    var repSearchBar:UISearchBar = UISearchBar()
    var repResultsTableView:TableView = TableView()
    var repSearchResults:[String] = []
    

    //requested by customer switch
    var reqByCustLbl:GreyLabel!
    var reqByCustSwitch:UISwitch = UISwitch()
    
    //description textview
    var descriptionLbl:GreyLabel!
    var descriptionView:UITextView!

    var keyBoardShown:Bool = false
    
    var editsMade:Bool = false
    
   
    //init for new
    init(){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        //for an empty lead to start things off
    }
    
    
    
    
    //new from customer page
    init(_customer:String,_customerName:String){
        super.init(nibName:nil,bundle:nil)
                
        self.lead = Lead2(_ID: "0", _statusID: "1", _scheduleType: "", _createdBy: appDelegate.loggedInEmployee!.ID)
        self.lead.date = ""
        self.lead.time = ""
        self.lead.statusName = ""
                
        self.lead.customerID = _customer
        self.lead.customerName = _customerName
        self.lead.urgent = "0"
        self.lead.description = ""
        self.lead.rep = ""
        self.lead.repName = ""
        self.lead.deadline = ""
        self.lead.requestedByCust = "0"
        self.lead.daysAged = "0"
    
    }
    
    
    init(_lead:Lead2,_tasks:[Task2]){
        super.init(nibName:nil,bundle:nil)
        //print("lead init \(_leadID)")
        self.lead = _lead
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
        backButton.addTarget(self, action: #selector(LeadViewController.goBack), for: UIControl.Event.touchUpInside)
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
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        timeFormatterDB.dateFormat = "HH:mm"
        timeFormatter.dateFormat = "h:mm a"
        
       
        //Get lead list
        var parameters:[String:String]
            parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!]
            print("parameters = \(parameters)")
               
            self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/customers.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("response = \(response)")
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
        ////print("layout views")
        if(self.lead == nil){
            title =  "New Lead"
            submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditLeadViewController.submit))
           
            
            self.lead = Lead2(_ID: "0", _statusID: "1", _scheduleType: "", _createdBy: appDelegate.loggedInEmployee!.ID)
            self.lead.date = ""
            self.lead.time = ""
            self.lead.statusName = ""
            self.lead.customerID = nil
            self.lead.customerName = nil
            self.lead.urgent = "0"
            self.lead.description = ""
            self.lead.rep = ""
            self.lead.repName = ""
            self.lead.deadline = ""
            self.lead.requestedByCust = "0"
            self.lead.daysAged = "0"
            
            
        }else{
            if(self.lead.ID == "0"){
                //coming from customer page
                title =  "New Customer Lead"
                submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(NewEditLeadViewController.submit))
            }else{
                title =  "Edit Lead #" + self.lead.ID
                submitButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(NewEditLeadViewController.submit))
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
        setStatus(status: self.lead.statusID)
        
        //status picker
        self.statusPicker = Picker()
        self.statusPicker.tag = 1
        self.statusPicker.delegate = self
        //set status
        self.statusPicker.selectRow(Int(lead.statusID)! - 1, inComponent: 0, animated: false)
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
        let closeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.cancelStatusInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setStatusButton = BarButtonItem(title: "Set Status", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.handleStatusChange))
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
        let closeCustButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.cancelCustInput))
        
        custToolBar.setItems([closeCustButton], animated: false)
        custToolBar.isUserInteractionEnabled = true
        customerSearchBar.inputAccessoryView = custToolBar
        
    
        if(self.customerIDs.count == 0){
            customerSearchBar.isUserInteractionEnabled = false
        }
        if(lead.customerName != nil){
            customerSearchBar.text = lead.customerName!
        }
        
        self.customerResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.customerResultsTableView.delegate  =  self
        self.customerResultsTableView.dataSource = self
        self.customerResultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "customerCell")
        self.customerResultsTableView.alpha = 0.0
        
        
        //schedule type
        self.scheduleTypeLbl = GreyLabel()
        self.scheduleTypeLbl.text = "Schedule Type:"
        self.scheduleTypeLbl.textAlignment = .left
        self.scheduleTypeLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(scheduleTypeLbl)
        
        self.scheduleTypePicker = Picker()
        self.scheduleTypePicker.delegate = self
        self.scheduleTypePicker.dataSource = self
        self.scheduleTypePicker.tag = 2
        self.scheduleTypeTxtField = PaddedTextField(placeholder: "Schedule Type...")
        self.scheduleTypeTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.scheduleTypeTxtField.delegate = self
        self.scheduleTypeTxtField.inputView = scheduleTypePicker
        safeContainer.addSubview(self.scheduleTypeTxtField)
        
        
        let scheduleTypeToolBar = UIToolbar()
        scheduleTypeToolBar.barStyle = UIBarStyle.default
        scheduleTypeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        scheduleTypeToolBar.sizeToFit()
         let closeScheduleTypeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.cancelScheduleTypeInput))
        
        let setScheduleTypeButton = BarButtonItem(title: "Set Type", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.handleScheduleTypeChange))
        scheduleTypeToolBar.setItems([closeScheduleTypeButton, spaceButton, setScheduleTypeButton], animated: false)
        scheduleTypeToolBar.isUserInteractionEnabled = true
        scheduleTypeTxtField.inputAccessoryView = scheduleTypeToolBar
        
        
        if(lead.scheduleType != ""){
            scheduleTypeTxtField.text = scheduleTypeArray[Int(lead.scheduleType)!]
        }
        
        
        
        //apointment date and time
        self.aptLbl = GreyLabel()
        self.aptLbl.text = "Appointment:"
        self.aptLbl.textAlignment = .left
        self.aptLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(aptLbl)
        
        //date
        aptDatePickerView = DatePicker()
        aptDatePickerView.datePickerMode = UIDatePicker.Mode.date
        
        self.aptDateTxtField = PaddedTextField(placeholder: "Date...")
        self.aptDateTxtField.returnKeyType = UIReturnKeyType.next
        self.aptDateTxtField.delegate = self
        self.aptDateTxtField.tag = 8
        self.aptDateTxtField.inputView = self.aptDatePickerView
        safeContainer.addSubview(self.aptDateTxtField)
        
        let aptDateToolBar = UIToolbar()
        aptDateToolBar.barStyle = UIBarStyle.default
        aptDateToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        aptDateToolBar.sizeToFit()
        let closeAptDateButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.cancelAptDateInput))
        
        let setDateButton = BarButtonItem(title: "Set Date", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.handleAptDatePicker))
        aptDateToolBar.setItems([closeAptDateButton, spaceButton, setDateButton], animated: false)
        aptDateToolBar.isUserInteractionEnabled = true
        aptDateTxtField.inputAccessoryView = aptDateToolBar
        
        //time
        aptTimePickerView = DatePicker()
        aptTimePickerView.datePickerMode = UIDatePicker.Mode.time
        
        self.aptTimeTxtField = PaddedTextField(placeholder: "Time...")
        self.aptTimeTxtField.returnKeyType = UIReturnKeyType.next
        self.aptTimeTxtField.delegate = self
        self.aptTimeTxtField.tag = 8
        self.aptTimeTxtField.inputView = self.aptTimePickerView
        safeContainer.addSubview(self.aptTimeTxtField)
        
        let aptTimeToolBar = UIToolbar()
        aptTimeToolBar.barStyle = UIBarStyle.default
        aptTimeToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        aptTimeToolBar.sizeToFit()
        let closeAptTimeButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.cancelAptTimeInput))
        
        let setTimeButton = BarButtonItem(title: "Set Time", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.handleAptTimePicker))
        aptTimeToolBar.setItems([closeAptTimeButton, spaceButton, setTimeButton], animated: false)
        aptTimeToolBar.isUserInteractionEnabled = true
        aptTimeTxtField.inputAccessoryView = aptTimeToolBar
        
        if(lead.scheduleType == "" || lead.scheduleType == "0"){
            self.aptDateTxtField.isEnabled = false
            self.aptTimeTxtField.isEnabled = false
            self.aptDateTxtField.alpha = 0.5
            self.aptTimeTxtField.alpha = 0.5
            
        }else{
            self.aptDateTxtField.isEnabled = true
            self.aptTimeTxtField.isEnabled = true
            self.aptDateTxtField.alpha = 1.0
            self.aptTimeTxtField.alpha = 1.0
            
            
            //print("lead.date = \(lead.date)")
            //print("lead.dateRaw = \(lead.dateRaw)")
            if(lead.date != "" && lead.date != "null"){
               
                self.aptDateTxtField.text = lead.date!
                
                
            }
            
            if(lead.time != "" && lead.time != "null"){
                self.aptTimeTxtField.text = lead.time
            }
        }
        
        //deadline
        self.deadlineLbl = GreyLabel()
        self.deadlineLbl.text = "Deadline:"
        self.deadlineLbl.textAlignment = .left
        self.deadlineLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(deadlineLbl)
        
       
        deadlinePickerView = DatePicker()
        deadlinePickerView.datePickerMode = UIDatePicker.Mode.date
        
        
        self.deadlineTxtField = PaddedTextField(placeholder: "Date...")
        self.deadlineTxtField.returnKeyType = UIReturnKeyType.next
        self.deadlineTxtField.delegate = self
        self.deadlineTxtField.tag = 8
        self.deadlineTxtField.inputView = self.deadlinePickerView
        safeContainer.addSubview(self.deadlineTxtField)
        
        let deadlineToolBar = UIToolbar()
        deadlineToolBar.barStyle = UIBarStyle.default
        deadlineToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        deadlineToolBar.sizeToFit()
        let closeDeadlineButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.cancelDeadlineInput))
        let setDeadlineButton = BarButtonItem(title: "Set Deadline", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.handleDeadlinePicker))
        deadlineToolBar.setItems([closeDeadlineButton, spaceButton, setDeadlineButton], animated: false)
        deadlineToolBar.isUserInteractionEnabled = true
        deadlineTxtField.inputAccessoryView = deadlineToolBar
        
        
        //print("deadline = \(lead.deadline)")
        if(lead.deadline != "" && lead.deadline != "null"){
            self.deadlineTxtField.text = lead.deadline
        }
        
        
        //urgent
        self.urgentLbl = GreyLabel()
        self.urgentLbl.text = "Urgent:"
        self.urgentLbl.textAlignment = .left
        self.urgentLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(urgentLbl)
        
        if(self.lead.urgent != "0" && self.lead.urgent != ""){
            urgentSwitch.isOn = true
        }else{
            urgentSwitch.isOn = false
        }
        urgentSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        urgentSwitch.addTarget(self, action: #selector(NewEditLeadViewController.urgentSwitchValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(urgentSwitch)
        
    
        //sales rep
        self.repLbl = GreyLabel()
        self.repLbl.text = "Sales Rep:"
        self.repLbl.textAlignment = .left
        self.repLbl.translatesAutoresizingMaskIntoConstraints = false
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
        let closeRepButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.cancelRepInput))
       
        repToolBar.setItems([closeRepButton], animated: false)
        repToolBar.isUserInteractionEnabled = true
        repSearchBar.inputAccessoryView = repToolBar
        

        if(self.appDelegate.salesRepIDArray.count == 0){
            repSearchBar.isUserInteractionEnabled = false
        }
        
        
        if(lead.repName != ""){
            repSearchBar.text = lead.repName
        }
        
        
        self.repResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.repResultsTableView.delegate  =  self
        self.repResultsTableView.dataSource = self
        self.repResultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "repCell")
        self.repResultsTableView.alpha = 0.0
        
        //req by cust
        self.reqByCustLbl = GreyLabel()
        self.reqByCustLbl.text = "Requsted By Customer:"
        self.reqByCustLbl.textAlignment = .left
        self.reqByCustLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(reqByCustLbl)
        
        if(self.lead.requestedByCust != "0" && self.lead.requestedByCust != ""){
            reqByCustSwitch.isOn = true
        }else{
            reqByCustSwitch.isOn = false
        }
        
        reqByCustSwitch.translatesAutoresizingMaskIntoConstraints = false
        reqByCustSwitch.addTarget(self, action: #selector(NewEditLeadViewController.reqByCustSwitchValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(reqByCustSwitch)
        
        
        //description
        self.descriptionLbl = GreyLabel()
        self.descriptionLbl.text = "General Description:"
        self.descriptionLbl.textAlignment = .left
        self.descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.descriptionLbl)
        
        self.descriptionView = UITextView()
        self.descriptionView.layer.borderWidth = 1
        self.descriptionView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.descriptionView.layer.cornerRadius = 4.0
        self.descriptionView.returnKeyType = .done
        self.descriptionView.text = self.lead.description
        self.descriptionView.font = layoutVars.smallFont
        self.descriptionView.isEditable = true
        self.descriptionView.delegate = self
        self.descriptionView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.descriptionView)
        
        let descriptionToolBar = UIToolbar()
        descriptionToolBar.barStyle = UIBarStyle.default
        descriptionToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        descriptionToolBar.sizeToFit()
        let closeDescriptionButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(NewEditLeadViewController.cancelDescriptionInput))
        
        descriptionToolBar.setItems([closeDescriptionButton], animated: false)
        descriptionToolBar.isUserInteractionEnabled = true
        self.descriptionView.inputAccessoryView = descriptionToolBar
        
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
            "scheduleTypeLbl":self.scheduleTypeLbl,
            "scheduleTypeTxtField":self.scheduleTypeTxtField,
            "aptLbl":self.aptLbl,
            "aptDateTxtField":self.aptDateTxtField,
            "aptTimeTxtField":self.aptTimeTxtField,
            "deadlineLbl":self.deadlineLbl,
            "deadlineTxtField":deadlineTxtField,
            "urgentLbl":self.urgentLbl,
            "urgentSwitch":self.urgentSwitch,
            "repLbl":self.repLbl,
            "repSearchBar":self.repSearchBar,
            "repTable":self.repResultsTableView,
            "reqByCustLbl":self.reqByCustLbl,
            "reqByCustSwitch":self.reqByCustSwitch,
            "descriptionLbl":self.descriptionLbl,
            "descriptionView":self.descriptionView
            ] as [String:AnyObject]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusIcon(40)]-15-[customerSearchBar]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: dictionary))

        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[customerTable]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scheduleTypeLbl][scheduleTypeTxtField(208)]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[aptLbl][aptDateTxtField(100)]-[aptTimeTxtField(100)]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[deadlineLbl][deadlineTxtField(100)]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[urgentLbl][urgentSwitch]-|", options: [], metrics: metricsDictionary, views: dictionary))

        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[repLbl(80)]-10-[repSearchBar]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[repTable]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[reqByCustLbl][reqByCustSwitch]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLbl]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionView]-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[statusTxtField(40)]", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)]-10-[scheduleTypeLbl(40)]-[aptLbl(40)]-[deadlineLbl(40)]-[urgentLbl(40)]-[repLbl(40)]-10-[reqByCustLbl(40)]-[descriptionLbl(40)][descriptionView]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)][customerTable]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)]-10-[scheduleTypeLbl(40)]-[aptLbl(40)]-[deadlineLbl(40)]-[urgentLbl(40)]-[repLbl(40)][repTable]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)]-10-[scheduleTypeTxtField(40)]-[aptDateTxtField(40)]-[deadlineTxtField(40)]-[urgentLbl(40)]-[repLbl(40)][repTable]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[customerSearchBar(40)]-10-[scheduleTypeTxtField(40)]-[aptTimeTxtField(40)]-[deadlineTxtField(40)]-[urgentSwitch(40)]-[repSearchBar(40)]-10-[reqByCustSwitch(40)]-[descriptionLbl(40)][descriptionView]-10-|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
 
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
    
    
    @objc func cancelScheduleTypeInput(){
        //print("Cancel Schedule Type Input")
        self.scheduleTypeTxtField.resignFirstResponder()
    }
    
    @objc func cancelAptDateInput(){
        //print("Cancel Apt Date Input")
        self.aptDateTxtField.resignFirstResponder()
    }
    
    @objc func cancelAptTimeInput(){
        //print("Cancel Apt Time Input")
        self.aptTimeTxtField.resignFirstResponder()
    }
    
    @objc func cancelDeadlineInput(){
        //print("Cancel Deadline Input")
        self.deadlineTxtField.resignFirstResponder()
    }
    
    @objc func cancelRepInput(){
        //print("Cancel Rep Input")
        self.repSearchBar.resignFirstResponder()
        self.repResultsTableView.alpha = 0.0
    }
    
    @objc func cancelDescriptionInput(){
        //print("Cancel Description Input")
        self.descriptionView.resignFirstResponder()
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //print("shouldChangeTextInRange")
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
   
    
    func textViewDidBeginEditing(_ textView: UITextView) {        //print("textFieldDidBeginEditing")
       
    }
    
     func textViewDidEndEditing(_ textView: UITextView) {
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
        //print("pickerview tag: \(pickerView.tag)")
        var count:Int = 0
        if(pickerView.tag == 1){
            count = self.statusArray.count
        }else{
            count = self.scheduleTypeArray.count
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
                myImageView.image = UIImage(named:"doneStatus.png")
                break
            case 3:
                myImageView.image = UIImage(named:"cancelStatus.png")
                break
            case 4:
                myImageView.image = UIImage(named:"waitingStatus.png")
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
            rowString = scheduleTypeArray[row]
            let myLabel = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
            myLabel.font = layoutVars.smallFont
            myLabel.text = rowString
            myView.addSubview(myLabel)
            
        }
        return myView
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        //print("pickerview tag: \(pickerView.tag)")
        if(pickerView.tag == 1){
            lead.statusID = "\(row + 1)"
            
        }else{
            lead.scheduleType = "\(row)"
            self.scheduleTypeTxtField.text = self.scheduleTypeArray[self.scheduleTypePicker.selectedRow(inComponent: 0)]
            
            if(row == 0){
                self.aptDateTxtField.isEnabled = false
                self.aptTimeTxtField.isEnabled = false
                
                self.aptDateTxtField.alpha = 0.5
                self.aptTimeTxtField.alpha = 0.5
                
                self.lead.date = ""
                self.lead.time = ""
                self.aptDateTxtField.text = ""
                self.aptTimeTxtField.text = ""
            }else{
                self.aptDateTxtField.isEnabled = true
                self.aptTimeTxtField.isEnabled = true
                self.aptDateTxtField.alpha = 1.0
                self.aptTimeTxtField.alpha = 1.0
            }
            
        }
 
    }
 
    func cancelPicker(){
        self.statusTxtField.resignFirstResponder()
        self.scheduleTypeTxtField.resignFirstResponder()
    }
    
    @objc func handleStatusChange(){
        self.statusTxtField.resignFirstResponder()
        lead.statusID = "\(self.statusPicker.selectedRow(inComponent: 0) + 1)"
        setStatus(status: lead.statusID)
        editsMade = true
    }
    
    func setStatus(status: String) {
        //print("set status \(status)")
        switch (status) {
        case "1":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"inProgressStatus.png")
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
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
    
    @objc func handleScheduleTypeChange(){
        //print("handle scheduleType change")
        self.scheduleTypeTxtField.resignFirstResponder()
        lead.scheduleType = "\(self.scheduleTypePicker.selectedRow(inComponent: 0))"
        self.scheduleTypeTxtField.text = self.scheduleTypeArray[self.scheduleTypePicker.selectedRow(inComponent: 0)]
        
        if(self.scheduleTypePicker.selectedRow(inComponent: 0) == 0){
            self.aptDateTxtField.isEnabled = false
            self.aptTimeTxtField.isEnabled = false
            self.aptDateTxtField.alpha = 0.5
            self.aptTimeTxtField.alpha = 0.5
            self.lead.date = ""
            self.lead.time = ""
            self.aptDateTxtField.text = ""
            self.aptTimeTxtField.text = ""
        }else{
            self.aptDateTxtField.isEnabled = true
            self.aptTimeTxtField.isEnabled = true
            self.aptDateTxtField.alpha = 1.0
            self.aptTimeTxtField.alpha = 1.0
        }
        
        editsMade = true
    }
    
    
    @objc func handleAptDatePicker(){
        //print("handleAptDatePicker")
        self.aptDateTxtField.resignFirstResponder()
        lead.date = dateFormatterDB.string(from: aptDatePickerView.date)
        self.aptDateTxtField.text = dateFormatter.string(from: aptDatePickerView.date)
        editsMade = true
    }
    
    @objc func handleAptTimePicker(){
        //print("handleAptTimePicker")
        self.aptTimeTxtField.resignFirstResponder()
        lead.time = timeFormatterDB.string(from: aptTimePickerView.date)
        self.aptTimeTxtField.text = timeFormatter.string(from: aptTimePickerView.date)
        editsMade = true
    }
    
    @objc func handleDeadlinePicker(){
        //print("handleDeadlinePicker")
        self.deadlineTxtField.resignFirstResponder()
        lead.deadline = dateFormatterDB.string(from: aptDatePickerView.date)
        self.deadlineTxtField.text = dateFormatter.string(from: deadlinePickerView.date)
        editsMade = true
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
                lead.customerID = nil
                lead.customerName = nil
            }else{
                self.customerResultsTableView.alpha = 1.0
            }
            break
        default://Rep
            if (searchText.count == 0) {
                self.repResultsTableView.alpha = 0.0
                lead.rep = ""
                lead.repName = ""
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
                self.view.frame.origin.y -= self.descriptionView.frame.height - 30
                
            }, completion: { finished in
                // //print("Napkins opened!")
            })
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
        
        if(searchBar.tag == 1){
            self.customerResultsTableView.reloadData()
            
        }else{
            if(self.view.frame.origin.y < 0){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.view.frame.origin.y += self.descriptionView.frame.height - 30
                
                
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
            //break
        case "REP":
            let searchString = self.repSearchBar.text!.lowercased()
            let cell:CustomerTableViewCell = repResultsTableView.dequeueReusableCell(withIdentifier: "repCell") as! CustomerTableViewCell
           
            cell.nameLbl.text = self.repSearchResults[indexPath.row]
            cell.name = self.repSearchResults[indexPath.row]
            if let i = self.appDelegate.salesRepNameArray.index(of: cell.nameLbl.text!) {
                cell.id = self.appDelegate.salesRepIDArray[i]
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
            //break
        
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
            lead.customerID = currentCell.id
            lead.customerName = currentCell.name
            
            customerSearchBar.text = currentCell.name
            customerResultsTableView.alpha = 0.0
            customerSearchBar.resignFirstResponder()
            break
        case "REP":
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
            lead.rep = currentCell.id
            lead.repName = currentCell.name
            
            repSearchBar.text = currentCell.name
            repResultsTableView.alpha = 0.0
            repSearchBar.resignFirstResponder()
            break
        default:
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
            lead.customerID = currentCell.id
            lead.customerName = currentCell.name
            
            customerSearchBar.text = currentCell.name
            customerResultsTableView.alpha = 0.0
            customerSearchBar.resignFirstResponder()
            break
          
        
       // print("selected customer id = \(self.customerSelectedID)")
       // print("selected rep id = \(self.repSelectedID)")
    }
        editsMade = true
    }
    
    
    
    
    /////////////// Switch Methods   ///////////////////////
   
    
    @objc func urgentSwitchValueDidChange(sender:UISwitch!)
    {
        //print("switchValueDidChange groupImages = \(groupImages)")
        
        if (sender.isOn == true){
            //print("on")
            lead.urgent = "1"
            editsMade = true
        }
        else{
            //print("off")
            lead.urgent = "0"
        }
    }
    
    @objc func reqByCustSwitchValueDidChange(sender:UISwitch!)
    {
        ////print("switchValueDidChange groupImages = \(groupImages)")
        
        if (sender.isOn == true){
            //print("on")
            lead.requestedByCust = "1"
            editsMade = true
        }
        else{
            //print("off")
            lead.requestedByCust = "0"
        }
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validateFields()->Bool{
        //print("validate fields")
       // print("lead.scheduleType = \(lead.scheduleType)")
        //customer check
        if(lead.customerID == nil){
            //print("select a customer")
            self.layoutVars.playErrorSound()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Lead", _message: "Select a Customer")
            return false
        }
        
        //type check
        if(lead.scheduleType == ""){
            //print("select a schedule type")
            self.layoutVars.playErrorSound()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Lead", _message: "Select a Schedule Type")
            return false
        }
        
        if(lead.scheduleType == "1"){
            if(lead.date == "" || lead.date == "null"){
                //print("select an apt date")
                self.layoutVars.playErrorSound()
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Lead", _message: "Select an Appointment Date")
                return false
            }
        }
        
        //rep check
        if(lead.rep == ""){
            //print("select a sales rep")
            self.layoutVars.playErrorSound()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Lead", _message: "Select a Sales Rep.")
            return false
        }
        
        //description check
        if(descriptionView.text.count == 0){
            //print("add a description")
            self.layoutVars.playErrorSound()
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Lead", _message: "Provide a General Description")
            return false
        }
        
        
        return true
        
        
    }
        
    
    
    @objc func submit(){
        //print("submit lead")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        
        if(!validateFields()){
            //print("didn't pass validation")
            return
        }
        //validate all fields
        
        lead.description = self.descriptionView.text
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        
        let parameters:[String:String]
        parameters = ["leadID": self.lead.ID, "createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), "custID": self.lead.customerID!, "urgent": self.lead.urgent,"repID": self.lead.rep, "requestedByCust": self.lead.requestedByCust, "description": lead.description , "timeType": self.lead.scheduleType, "date": self.lead.date, "time": self.lead.time, "deadline": self.lead.deadline, "status": self.lead.statusID,"companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!] as! [String : String]
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/lead.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("lead response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    self.layoutVars.playSaveSound()
                    self.json = JSON(json)
                    let newLeadID = self.json["leadID"].stringValue
                    self.lead.ID = newLeadID
                    
                    
                    self.editsMade = false // avoids the back without saving check
                    
                    if(self.title == "New Lead"){
                        _ = self.navigationController?.popViewController(animated: false)
                        
                        self.delegate.getLeads(_openNewLead: true)
                    }else if(self.title == "New Customer Lead"){
                        //no delegate method
                        
                        _ = self.navigationController?.popViewController(animated: false)
                        self.delegate.getLeads(_openNewLead: true)
                        
                        
                    }else{
                        self.editDelegate.updateLead(_lead: self.lead,_newStatusValue:"na")
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
    
    
    
    
    
    
    func updateTable(_points:Int){
        //print("updateTable")
        //getLead()
    }
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
        getPickerInfo()
       }
}
