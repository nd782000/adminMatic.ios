//
//  NewCustomerLookUPViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/31/19.
//  Copyright © 2019 Nick. All rights reserved.
//



//  Edited for safeView



import Foundation
import UIKit
import Alamofire
import SwiftyJSON



class NewCustomerLookUpViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, EditCustomerDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    
    var delegate:CustomerListDelegate?
    
   
    var customerArray = [Customer2]()
    var customerSearchResults = [Customer2]()
    
    
    //lookUp
    var lookUpLbl:GreyLabel!
    
    //customer search
    var customerSearchBar:UISearchBar = UISearchBar()
    var customerResultsTableView:TableView = TableView()
   
    var selectedCustomerID:String!
    var selectedCustomerName:String!
    
   
    var newCustomerBtn:Button = Button(titleText: "Add New Customer")

    
    
    
    
    
    init(_customerArray:[Customer2]){
        super.init(nibName:nil,bundle:nil)
        
        self.customerArray = _customerArray
       
        //print("lead init \(_leadID)")
        //for an empty lead to start things off
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
        backButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel?.textColor = layoutVars.buttonColor1
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
       
         title = "Customer Look Up"
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
       
        
        //customer select
        customerSearchBar.placeholder = "Street Address..."
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
        let closeCustButton = BarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelCustInput))
        
        custToolBar.setItems([closeCustButton], animated: false)
        custToolBar.isUserInteractionEnabled = true
        customerSearchBar.inputAccessoryView = custToolBar
        
        
        //look up text
        self.lookUpLbl = GreyLabel()
        self.lookUpLbl.text = "Enter street address to search existing customers.  We want to avoid duplicate customer entry."
        self.lookUpLbl.numberOfLines = 0
        safeContainer.addSubview(lookUpLbl)
        
        
        
        self.customerResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.customerResultsTableView.delegate  =  self
        self.customerResultsTableView.dataSource = self
        self.customerResultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "customerCell")
        self.customerResultsTableView.alpha = 0.0
        
        self.customerResultsTableView.rowHeight = 50
        
        safeContainer.addSubview(customerResultsTableView)
        
        
        
        

        self.newCustomerBtn.addTarget(self, action: #selector(self.newCustomer), for: UIControl.Event.touchUpInside)
        
        safeContainer.addSubview(newCustomerBtn)
        
        
        

        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150] as [String:Any]
        
        //auto layout group
        let dictionary = [
            "lookUpLbl":self.lookUpLbl,
            "customerSearchBar":self.customerSearchBar,
            "customerTable":self.customerResultsTableView,
            "newBtn":self.newCustomerBtn
            ] as [String:AnyObject]
        
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[customerSearchBar]-|", options: [], metrics: metricsDictionary, views: dictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[lookUpLbl]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[customerTable]-|", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[newBtn]|", options: [], metrics: metricsDictionary, views: dictionary))
        

       
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[customerSearchBar(40)][lookUpLbl(80)]", options: [], metrics: metricsDictionary, views: dictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[customerSearchBar(40)][customerTable][newBtn(40)]|", options: [], metrics: metricsDictionary, views: dictionary))
        
        
        
        
    }
    
   
    
    @objc func cancelCustInput(){
        //print("Cancel Cust Input")
        self.customerSearchBar.resignFirstResponder()
        self.customerResultsTableView.alpha = 0.0
    }
    
    
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    
    
    
    /////////////// Search Delegate Methods   ///////////////////////
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        //print("search edit")
        //print("searchText.count = \(searchText.count)")
       
       
            if (searchText.count == 0) {
                self.customerResultsTableView.alpha = 0.0
                self.lookUpLbl.alpha = 1.0
               

            }else{
                //print("set cust table alpha to 1")
                self.customerResultsTableView.alpha = 1.0
                self.lookUpLbl.alpha = 0
            }
        
        
        
        filterSearchResults()
    }
    
    
    
    func filterSearchResults(){
        
        
            customerSearchResults = []
        
       
            //print(" text = \(customerSearchBar.text!.lowercased())")
            self.customerSearchResults = self.customerArray.filter({( aCustomer: Customer2 ) -> Bool in
                return (aCustomer.address!.lowercased().range(of: customerSearchBar.text!.lowercased(), options:.regularExpression) != nil)})
        
       
        
            self.customerResultsTableView.reloadData()
        
    }
    
    
   
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.customerResultsTableView.reloadData()
            
       
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
        // self.tableViewMode = "TASK"
        
       
            self.customerResultsTableView.reloadData()
            
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.customerResultsTableView.reloadData()
        
        searchBar.resignFirstResponder()
        
        
    }
    
    
    
    
    /////////////// Table Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        
        count = self.customerSearchResults.count
        
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
            
            //print("customer name: \(self.customerNames[indexPath.row])")
            let searchString = self.customerSearchBar.text!.lowercased()
            let cell:CustomerTableViewCell = customerResultsTableView.dequeueReusableCell(withIdentifier: "customerCell") as! CustomerTableViewCell
            
           
        cell.name = customerSearchResults[indexPath.row].sysname
        cell.address = customerSearchResults[indexPath.row].address
        cell.id = customerSearchResults[indexPath.row].ID
        
            cell.nameLbl.text = cell.name
        
            
            //text highlighting
            let baseString:NSString = cell.address as NSString
            let highlightedText = NSMutableAttributedString(string: cell.address)
            var error: NSError?
            let regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error1 as NSError {
                error = error1
                regex = nil
            }
            if let regexError = error {
                print("error \(regexError)")
            } else {
                for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                    highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
            }
            cell.addressLbl.attributedText = highlightedText
            
            
            return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
            self.selectedCustomerID = currentCell.id
            self.selectedCustomerName = currentCell.name
        
            
        let customerViewController = CustomerViewController(_customerID: self.selectedCustomerID, _customerName: self.selectedCustomerName)
        navigationController?.pushViewController(customerViewController, animated: false)
        
    }
    
    
    
    
    
    
    
    
    
    @objc func goBack(){
        print("go back")
        _ = navigationController?.popViewController(animated: false)
        
        
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
    
    
    
    
    
   
    
    
    @objc func newCustomer(){
        //print("new customer")
        //show new/edit customer view
        let newEditCustomerViewController = NewEditCustomerViewController()
        newEditCustomerViewController.editDelegate = self
        navigationController?.pushViewController(newEditCustomerViewController, animated: false )
    }
    
    func updateCustomer(_customerID:String){
        print("update customer in customer look up")
       // goBack()
        
        if self.delegate != nil{
            self.delegate?.updateList(_customerID:_customerID,_newCustomer:true)
            
        }
        
        
        
    }
    
    func updateTable(_points:Int){
        //print("updateTable")
       
    }
    
    
}
