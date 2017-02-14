//
//  HFFeedViewController.swift
//  Hack FSU
//
//  Created by Todd Littlejohn on 10/22/15.
//  Copyright © 2017 Cam. All rights reserved.
//

import UIKit
import Glyptodon
import FlatUIKit
import Alamofire
import SwiftyJSON
import ReachabilitySwift

class HFFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UI Outlets
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var feedSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableViewContainerView: UIView!
    
    let apiURL = NSURL(string: "https://hackfsu.com/api/hackathon/get/updates")!
    let scheduleapiURL = NSURL(string: "https://hackfsu.com/api/hackathon/get/schedule_items")!
   
    var titles = [String]()
    var contents = [String]()
    var updatesDates = [String]()
    
    var scheduleNames = [String]()
    
    var refreshControl: UIRefreshControl!
    var alamoCalled = false;
    var didFinishFetching = false;
    var wasntAbleToConnectFirst = false
    
    var reachability: Reachability?
    
    var thursdayFeedArray:[HFScheduleItem] = [HFScheduleItem]()
    var fridayFeedArray:[HFScheduleItem] = [HFScheduleItem]()
    var saturdayFeedArray:[HFScheduleItem] = [HFScheduleItem]()
    var sundayFeedArray:[HFScheduleItem] = [HFScheduleItem]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTableView.setContentOffset(CGPointZero, animated: false)
        //getUpdatesFromParse()
        //getScheduleItemsFromParse()
        //checkForContent()
        checkForContent()
        self.feedTableView.rowHeight = UITableViewAutomaticDimension
        self.feedTableView.estimatedRowHeight = 44.0
        feedTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Setting Navigation Bar Color
        self.navigationController?.navigationBar.barTintColor = UIColor._hackRed()
        self.feedSegmentControl?.tintColor = UIColor._hackRed()
        self.navigationController?.navigationBar.tintColor = .whiteColor()

        // Setting Navigation Bar Title 
        self.navigationItem.title = "HACKFSU"
        let attributesDictionary = [NSFontAttributeName: UIFont(name: "UniSansHeavyCAPS", size: 25)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = attributesDictionary

//        Putting logo in the top bar
//        let logo = UIImage(named: "logo.png") as UIImage?
//        let imageView = UIImageView(image:logo)
//        imageView.frame.size.width = 100;
//        imageView.frame.size.height = 30;
//        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
//        self.navigationItem.titleView = imageView
        
        self.feedTableView.showsVerticalScrollIndicator = false
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        feedTableView.addSubview(refreshControl)
        
        callAlamo(apiURL)
        callAlamo(scheduleapiURL);
    }
    
    func checkForContent() {
        if didFinishFetching == false {
            feedTableView.alpha = 0.0
            tableViewContainerView.glyptodon.show("Loading Feed.\nPlease Wait.")
        } else {
            tableViewContainerView.glyptodon.hide()
            feedTableView.alpha = 1.0
        }
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.titles.removeAll()
        self.contents.removeAll()
        self.updatesDates.removeAll()
        
        self.thursdayFeedArray.removeAll()
        self.fridayFeedArray.removeAll()
        self.saturdayFeedArray.removeAll()
        self.sundayFeedArray.removeAll()
        self.scheduleNames.removeAll()
       
        self.feedTableView.reloadData()
        
        callAlamo(apiURL)
        callAlamo(scheduleapiURL)
        
        if (alamoCalled == true) {
            let delay = 0.75 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.refreshControl.endRefreshing()
                self.feedTableView.reloadData()
            }
            self.alamoCalled = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        //checkForContent()
        //callAlamo(apiURL)
    }
    
    override func viewDidAppear(animated: Bool) {
        //getUpdatesFromParse()
        //callAlamo(apiURL)
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:",name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() && wasntAbleToConnectFirst == true {
            checkForContent()
            refresh(self)
        } else {
            print("Network not reachable")
        }
    }
    
    func callAlamo(url : NSURL) {
        Alamofire.request(.GET, url, encoding: .JSON).validate().responseJSON(completionHandler: {
            response in
            
            switch response.result {
                case .Success(let json):
                    self.parseResults(JSON(response.result.value!), url: url)
                    self.alamoCalled = true
                case .Failure(let error):
                    if let err = error as? NSURLError where err == .NotConnectedToInternet {
                        // no internet connection
                        self.feedTableView.alpha = 0.0
                        self.tableViewContainerView.glyptodon.show("No Internet Connection")
                    } else {
                        // other failures
                        print("fuck")
                    }
                    self.wasntAbleToConnectFirst = true
            }
        })
    }
    
    func parseResults(theJSON : JSON, url: NSURL) {
        
        if (url == apiURL) {
        
        for result in theJSON["updates"].arrayValue {
            let title = result["title"].stringValue
            let content = result["content"].stringValue
            let dates = result["submit_time"].stringValue
            
            self.contents.append(content)
            self.titles.append(title)
            self.updatesDates.append(dates)
      
        }
            
        }
        else if (url == scheduleapiURL) {
            for results in theJSON["schedule_items"].arrayValue {
                let name = results["name"].stringValue
                let description = results["description"].stringValue
                let startTime = results["start"].stringValue
                
                let formatInput = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                
                let thaTime = theTIMEBIH(startTime, formatIn: formatInput, formatOut: "yyyy-MM-dd");
                
                if thaTime.rangeOfString("2017-02-16") != nil {
                    let finalStartTime = theTIMEBIH(startTime, formatIn: formatInput, formatOut: "h:mm a");
                    
                    let newScheduleItem = HFScheduleItem(title: name,
                                                         subtitle: description,
                                                         start: finalStartTime)
                    self.thursdayFeedArray.append(newScheduleItem)
                }
                
                else if thaTime.rangeOfString("2017-02-17") != nil{
                    let finalStartTime = theTIMEBIH(startTime, formatIn: formatInput, formatOut: "h:mm a");
       
                    let newScheduleItem = HFScheduleItem(title: name,
                                                         subtitle: description,
                                                         start: finalStartTime)
                    self.fridayFeedArray.append(newScheduleItem)
                }
                else if thaTime.rangeOfString("2017-02-18") != nil{
            
                let finalStartTime = theTIMEBIH(startTime, formatIn: formatInput, formatOut: "h:mm a");
                
                let newScheduleItem = HFScheduleItem(title: name,
                                                     subtitle: description,
                                                     start: finalStartTime)
                self.saturdayFeedArray.append(newScheduleItem)
                }
                else if thaTime.rangeOfString("2017-02-19") != nil{
                    let finalStartTime = theTIMEBIH(startTime, formatIn: formatInput, formatOut: "h:mm a");
                    
                    let newScheduleItem = HFScheduleItem(title: name,
                                                         subtitle: description,
                                                         start: finalStartTime)
                    self.didFinishFetching = true
                    self.sundayFeedArray.append(newScheduleItem)
                }
            }
            
        }
        checkForContent()
        self.feedTableView.reloadData()
    }
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let update = 0
        let scheudle = 1
        
        switch (self.feedSegmentControl.selectedSegmentIndex) {
        case update:
            return titles.count
        case scheudle:
            return 4
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.feedSegmentControl.selectedSegmentIndex == 0 {
            return 1
        } else {
            if section == 0 {
                return thursdayFeedArray.count
            } else if section == 1 {
                return fridayFeedArray.count
            } else if section == 2 {
                return saturdayFeedArray.count
            } else if section == 3 {
                return sundayFeedArray.count
            }else {
                return 0
            }
        }
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let update = 0
        let scheudle = 1
        
        let tempCellColor = UIColor.colorFromHex(0xFBFBFB)
        
        switch (self.feedSegmentControl.selectedSegmentIndex) {
        case update:
            
            let cell:HFUpdateTableViewCell = tableView.dequeueReusableCellWithIdentifier("HFUpdateTableViewCell") as! HFUpdateTableViewCell
            //let update = updateFeedArray[indexPath.section]
            cell.title.text = titles[indexPath.section]
            //cell.subTitle.text = update.getContent()
            cell.subTitle.text = contents[indexPath.section]
            
            let hi = updatesDates[indexPath.section]
            
            cell.timestamp.text = theTIMEBIH(hi, formatIn: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", formatOut: "E h:mm a");

            cell.configureFlatCellWithColor(tempCellColor, selectedColor: tempCellColor, roundingCorners: .AllCorners)
            cell.cornerRadius = 3.5
            cell.backgroundColor = UIColor.colorFromHex(0xEDECF3)
            return cell
            
        case scheudle:
            
            let cell:HFScheduleTableViewCell = tableView.dequeueReusableCellWithIdentifier("HFScheduleTableViewCell") as! HFScheduleTableViewCell
            let scheduleItem:HFScheduleItem!
            
            if indexPath.section == 0 {
                scheduleItem = thursdayFeedArray[indexPath.row]
            } else if indexPath.section == 1 {
                scheduleItem = fridayFeedArray[indexPath.row]
            } else if indexPath.section == 2 {
                scheduleItem = saturdayFeedArray[indexPath.row]
            } else if indexPath.section == 3 {
                scheduleItem = sundayFeedArray[indexPath.row]
            }
            else {
                scheduleItem = thursdayFeedArray[indexPath.row]
                // SWITCH TO A DEFAULT ITEM
            }
            
            cell.title.text = scheduleItem.getTitle()
            cell.subtitle.text = scheduleItem.getSubtitle()
            cell.time.text = "\(scheduleItem.getStartTime())"
            
            if indexPath.row == 0 {
                cell.configureFlatCellWithColor(tempCellColor, selectedColor: tempCellColor, roundingCorners: [.TopLeft, .TopRight])
                cell.cornerRadius = 3.5
            } else if indexPath.section == 0 && indexPath.row == thursdayFeedArray.count - 1  {
                cell.configureFlatCellWithColor(tempCellColor, selectedColor: tempCellColor, roundingCorners: [.BottomLeft,
                    .BottomRight])
                cell.cornerRadius = 3.5
            } else if indexPath.section == 1 && indexPath.row == fridayFeedArray.count - 1  {
                cell.configureFlatCellWithColor(tempCellColor, selectedColor: tempCellColor, roundingCorners: [.BottomLeft,
                    .BottomRight])
                cell.cornerRadius = 3.5
            } else if indexPath.section == 2 && indexPath.row == saturdayFeedArray.count - 1  {
                cell.configureFlatCellWithColor(tempCellColor, selectedColor: tempCellColor, roundingCorners: [.BottomLeft,
                    .BottomRight])
                cell.cornerRadius = 3.5
            } else if indexPath.section == 3 && indexPath.row == sundayFeedArray.count - 1  {
                cell.configureFlatCellWithColor(tempCellColor, selectedColor: tempCellColor, roundingCorners: [.BottomLeft,
                    .BottomRight])
                cell.cornerRadius = 3.5
            }
            
            else {
                cell.configureFlatCellWithColor(tempCellColor, selectedColor: tempCellColor, roundingCorners: .AllCorners)
                cell.cornerRadius = 0
            }
        
            cell.backgroundColor = UIColor.colorFromHex(0xEDECF3)
            
            
            return cell
            
        default: let cell = UITableViewCell(); return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6.0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 6.5))
        footerView.backgroundColor = UIColor.colorFromHex(0xEDECF3)
        
        return footerView
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell:ScheduleHeaderCell = (tableView.dequeueReusableCellWithIdentifier("scheduleHeader") as? ScheduleHeaderCell)!
        cell.backgroundColor = UIColor.colorFromHex(0xEDECF3) // CLEAR
        
        if section == 0 {
            cell.headerLabel.text = "Thursday"
        } else if section == 1 {
            cell.headerLabel.text = "Friday"
        } else if section == 2 {
            cell.headerLabel.text = "Saturday"
        } else if section == 3 {
            cell.headerLabel.text = "Sunday"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.feedSegmentControl.selectedSegmentIndex == 1 {
            return 34.0
        } else {
            return 0.0
        }
    }
    
    func theTIMEBIH(date: String, formatIn: String, formatOut: String) -> String {
        
        let dateFormatterGet = NSDateFormatter()
        dateFormatterGet.dateFormat = formatIn
        
        let dateFormatterPrint = NSDateFormatter()
        dateFormatterPrint.dateFormat = formatOut
        
        let date: NSDate? = dateFormatterGet.dateFromString(date)
        return dateFormatterPrint.stringFromDate(date!)
    }

    
    @IBAction func feedSegControlValueChanged(sender: AnyObject) {

        self.feedTableView.reloadData()

    }

}
