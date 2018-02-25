//
//  adminPanelViewController.swift
//  HackFSU
//
//  Created by Andres Ibarra on 1/31/18.
//  Copyright © 2018 HackFSU. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



class adminPanelViewController: UIViewController {

    @IBOutlet var returnButton: UIButton!
    var adminOptions = ["Scan", "Post Announcement"]
    
    @IBOutlet var adminOptionsView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(routes.getHackerEvents, method: .get, parameters: nil, encoding: JSONEncoding.default).validate().responseJSON(completionHandler: {
            response in
            //print(response)
            
            switch response.result {
            case .success(_):
                self.parseResults(theJSON: JSON(response.result.value!))
            case .failure(_):
                print("Failed to retrive Events")
            }
        })
        
        
        
        returnButton.layer.borderWidth = 3
        returnButton.layer.cornerRadius = 15
        returnButton.layer.masksToBounds = true
        returnButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        adminOptionsView.delegate = self
        adminOptionsView.dataSource = self
        adminOptionsView.sectionFooterHeight = CGFloat(5)
        
        
   
       
    }

    @IBAction func returnToAdminPanel(unwindSegue: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let index = self.adminOptionsView.indexPathForSelectedRow{
            adminOptionsView.deselectRow(at: index, animated: true)
        }
    }

}

extension adminPanelViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //print("In here")
        let footerView = UIView()
        footerView.backgroundColor =  UIColor.gray
        footerView.alpha = 1
        return footerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        return tableView.bounds.height/CGFloat(adminOptions.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adminOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminPanelOptions") as! adminPanelTableCell
        
        cell.optionLabel.text = adminOptions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(adminOptions[indexPath.row])
        
        if adminOptions[indexPath.row] == "Scan"{
            let vc = storyboard?.instantiateViewController(withIdentifier: "eventLabel")
            self.present(vc!, animated: true, completion: nil)
        }else if adminOptions[indexPath.row] == "Post Announcement"{
            let vc = storyboard?.instantiateViewController(withIdentifier: "postAnnouncements")
            self.present(vc!, animated: true, completion: nil)
            
           
        }
    }
    
    
    func parseResults(theJSON: JSON) {
       
        for result in theJSON["events"].arrayValue {
            //print(result["id"].stringValue)
            if !eventList.contains(where: {$0 == result["name"].stringValue}){
                eventList.append(result["name"].stringValue)
                eventId[result["name"].stringValue] = result["id"].stringValue
            }
            
        }
  
    }
        
  

}

class adminPanelTableCell: UITableViewCell{
    
    @IBOutlet var optionLabel: UILabel!
    
    
}
