//
//  ItemListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire

 

class ItemListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, NoInternetDelegate{
    var indicator: SDevIndicator!
    var totalItems:Int!
    
    var searchController:UISearchController!
    
    var itemTableView:TableView = TableView()
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var sections : [(index: Int, length :Int, title: String)] = Array()
    var itemsArray:[Item2] = []
    var itemsSearchResults:[Item2] = []
    var shouldShowSearchResults:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Item List"
        view.backgroundColor = layoutVars.backgroundColor
        getItemList()
    }
    
   
    func getItemList(){
           print("load link list")
           
           if CheckInternet.Connection() != true{
               self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
               return
           }
           
           for view in self.view.subviews{
                      view.removeFromSuperview()
                  }
           
           // Show Indicator
           indicator = SDevIndicator.generate(self.view)!
           
           //Get lead list
                  var parameters:[String:AnyObject]
                  parameters = ["sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject]
                  print("parameters = \(parameters)")
                  
                  self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/items.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                      .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                      .responseString { response in
                          print("lead response = \(response)")
                      }
                      .responseJSON() {
                          response in
            
            do{
                //created the json decoder
                let json = response.data
                //print("json = \(json)")
                
                let decoder = JSONDecoder()
                let parsedData = try decoder.decode(ItemArray.self, from: json!)
                
                print("parsedData = \(parsedData)")
                
                let items = parsedData
                
                let itemCount = items.items.count
                print("item count = \(itemCount)")
                
                for i in 0 ..< itemCount {
                    //create an object
                    print("create a item object \(i)")
                    self.itemsArray.append(items.items[i])
                }
                
                // build sections based on first letter(json is already sorted alphabetically)
                var index = 0;
                var firstCharacterArray:[String] = [" "]
                
                for i in 0 ..< self.itemsArray.count {
                    let stringToTest = self.itemsArray[i].name.uppercased()
                    let firstCharacter = String(stringToTest[stringToTest.startIndex])
                    if(i == 0){
                        firstCharacterArray.append(firstCharacter)
                    }
                    
                    if !firstCharacterArray.contains(firstCharacter) {
                        
                        //print("new")
                        let title = firstCharacterArray[firstCharacterArray.count - 1]
                        firstCharacterArray.append(firstCharacter)
                        
                        let newSection = (index: index, length: i - index, title: title)
                        self.sections.append(newSection)
                        index = i;
                    }
                    
                    if(i == self.itemsArray.count - 1){
                        let title = firstCharacterArray[firstCharacterArray.count - 1]
                        let newSection = (index: index, length: i - index + 1, title: title)
                        self.sections.append(newSection)
                    }
                    
                    
                }
                
                self.indicator.dismissIndicator()
                
                
                self.layoutViews()
                
            }catch let err{
                print(err)
            }

        }
    }
    

    func layoutViews(){
        
        // Close Indicator
        indicator.dismissIndicator()
        
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Items"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.backgroundColor = UIColor.clear
        
        
        //workaround for ios 11 larger search bar
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        self.itemTableView.delegate  =  self
        self.itemTableView.dataSource = self
        self.itemTableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "cell")
        
        safeContainer.addSubview(self.itemTableView)
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.countView)
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)

        
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemTableView,
            "view2":self.countView
        ] as [String : Any]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1][view2(30)]|", options:[], metrics: sizeVals, views: viewsDictionary))
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    
    
    /////////////// Search Methods   ///////////////////////
    
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResultsForSearchController \(String(describing: searchController.searchBar.text))")
        filterSearchResults()
    }
   
    func filterSearchResults(){
        self.itemsSearchResults = self.itemsArray.filter({( aItem: Item2) -> Bool in
            //return type name or name
            return (aItem.name!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
        })
        self.itemTableView.reloadData()
        
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.itemTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        shouldShowSearchResults = false
        self.itemTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.itemTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
   
    func willPresentSearchController(_ searchController: UISearchController){
        
        
    }
    
    
    func presentSearchController(searchController: UISearchController){
        
    }
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowSearchResults{
            return 1
        }else{
            return sections.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ////print("titleForHeaderInSection")
        if shouldShowSearchResults{
            return nil
        }else{
            
                return "    " + sections[section].title //hack way of indenting section text
                
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if shouldShowSearchResults{
            return nil
        }else{
            return sections.map { $0.title }
        }
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //print("heightForHeaderInSection")
        if shouldShowSearchResults{
            return 0
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection")
        if shouldShowSearchResults{
            self.countLbl.text = "\(self.itemsSearchResults.count) Item(s) Found"
            return self.itemsSearchResults.count
        } else {
            self.countLbl.text = "\(self.itemsArray.count) Active Items"
            return sections[section].length
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "cell") as! ItemTableViewCell
        itemTableView.rowHeight = 50.0
        if shouldShowSearchResults{
            
            print("cell for table - search")
          
            cell.item = self.itemsSearchResults[indexPath.row]
            let searchString = self.searchController.searchBar.text!.lowercased()
            //text highlighting
            let baseString:NSString = self.itemsSearchResults[indexPath.row].name! as NSString
            let highlightedText = NSMutableAttributedString(string: self.itemsSearchResults[indexPath.row].name!)
            
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
            cell.layoutViews()
            cell.nameLbl.attributedText = highlightedText
        } else {
            cell.item = self.itemsArray[sections[indexPath.section].index + indexPath.row]
            cell.layoutViews()
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! ItemTableViewCell;
            let itemViewController = ItemViewController(_item: currentCell.item)
            navigationController?.pushViewController(itemViewController, animated: false )
            tableView.deselectRow(at: indexPath!, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
        getItemList()
       }
}
