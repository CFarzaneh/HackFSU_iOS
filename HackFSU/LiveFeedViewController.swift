//
//  LiveFeedViewController.swift
//  HackFSU
//
//  Created by Cameron Farzaneh on 10/8/17.
//  Copyright © 2017 HackFSU. All rights reserved.
//

import UIKit
import CoreData

class LiveFeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Andres
        self.navigationController?.navigationBar.isHidden = true
        schedule = API.getSchedule(url: URL(string:"https://2017.hackfsu.com/api/hackathon/get/schedule_items")!)
        //
    }

    override func viewDidAppear(_ animated: Bool) {
        if (userNotLoggedIn == true) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(vc!, animated: true, completion: nil)
        }
        else {
            API.retriveUserInfo()
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            do {
                _ = try PersistenceService.context.fetch(fetchRequest)
            } catch {
                
            }
        }
    }
    
    var userNotLoggedIn: Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let count = try PersistenceService.context.count(for: fetchRequest)
            return count == 0 ? true : false
        } catch {
            return true
        }
    }
    
    //only needed to properly return from login
    @IBAction func returnToMainViewFromLogin(unwindSegue: UIStoryboardSegue) {
        
    }
  


}
