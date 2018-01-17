//
//  ViewController.swift
//  judgeViewTesting
//
//  Created by Andres Ibarra on 1/12/18.
//  Copyright © 2018 Andres Ibarra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//key is hack #, value is hack table
var givenHacks = ["1":"20", "2":"25", "3":""]
var nofirst = true
var nosecond = true
var nothird = true
//key = hack #
//value = superlative given
var superlatives = Dictionary<String, String>()

var superlativeOptions = [String]()

class InitialHackViewController: UIViewController {

    @IBOutlet var firstHackView: UIView!
    @IBOutlet var firstHackLabel: UILabel!
    
    @IBOutlet var secondHackView: UIView!
    @IBOutlet var secondHackLabel: UILabel!
    
    @IBOutlet var thirdHackView: UIView!
    @IBOutlet var thirdHackLabel: UILabel!
    
    @IBOutlet var startJudginButton: UIButton!
    @IBOutlet var leaveJudging: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //just randomizing for now
        givenHacks["1"] = nil
        givenHacks["2"] = nil
        givenHacks["3"] = nil
        
        Alamofire.request("https://api.hackfsu.com/api/judge/hacks", method: .get, parameters: nil, encoding: JSONEncoding.default).validate().responseJSON(completionHandler: {
            response in
            print(response)
            
            switch response.result {
            case .success(_):
                self.parseResults(theJSON: JSON(response.result.value!))
            case .failure(_):
                print("Failed to retrive User Info")
            }
        })
        
        
        
        //visual Formatting
        startJudginButton.layer.cornerRadius = 30.0
        startJudginButton.layer.masksToBounds = true
        leaveJudging.layer.cornerRadius = 30.0
        leaveJudging.layer.masksToBounds = true
        
        firstHackView.layer.cornerRadius = 30.0
        firstHackView.layer.masksToBounds = true
        firstHackView.isHidden = true
        secondHackView.layer.cornerRadius = 30.0
        secondHackView.layer.masksToBounds = true
        secondHackView.isHidden = true
        
        thirdHackView.layer.cornerRadius = 30.0
        thirdHackView.layer.masksToBounds = true
        thirdHackView.isHidden = true
        
        //positional Formatting
        firstHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: -80)
        secondHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: -80)
        thirdHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: -80)
        
        titleLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/8.5)
        leaveJudging.layer.position = CGPoint(x: (self.view.bounds.width)/4, y: (6*self.view.bounds.height)/7)
        startJudginButton.layer.position = CGPoint(x: (3*self.view.bounds.width)/4, y: (6*self.view.bounds.height)/7)

      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        
      
       
    }
    
    override func viewDidAppear(_ animated: Bool){
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.firstHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: -50)
            self.firstHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/4)
            self.firstHackLabel.layer.position = CGPoint(x: self.firstHackView.bounds.width/2, y: self.firstHackView.bounds.height/2)
            
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.secondHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: -50)
            self.secondHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: (1.8*self.view.bounds.height)/4)
            self.secondHackLabel.layer.position = CGPoint(x: self.secondHackView.bounds.width/2, y: self.secondHackView.bounds.height/2)
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.thirdHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: -50)
            self.thirdHackView.layer.position = CGPoint(x: self.view.bounds.width/2, y: (2.6*self.view.bounds.height)/4)
            self.thirdHackLabel.layer.position = CGPoint(x: self.thirdHackView.bounds.width/2, y: self.thirdHackView.bounds.height/2)
        }, completion: nil)
        
    }

   
    //only needed to properly return from login
    @IBAction func restartHacks(unwindSegue: UIStoryboardSegue) {
        
    }


}

extension InitialHackViewController{
    
    func parseResults(theJSON: JSON) {
        var hacks = [String]()
        
        for result in theJSON["hacks"].arrayValue {
            hacks.append(result.stringValue)
        }
        
        for result in theJSON["superlatives"].arrayValue {
            
            if !superlativeOptions.contains(where: {$0 == result.stringValue}){
                superlativeOptions.append(result.stringValue)
            }
        }
        
        
        if hacks.count == 0{
            //do nothing
        }else if hacks.count == 1{
            givenHacks["1"] = hacks[0]
           
        }else if hacks.count == 2{
            givenHacks["1"] = hacks[0]
            givenHacks["2"] = hacks[1]
        }else if hacks.count == 3{
            givenHacks["1"] = hacks[0]
            givenHacks["2"] = hacks[1]
             givenHacks["3"] = hacks[2]
        }
    
        if givenHacks["1"] != nil{
            nofirst = false
            firstHackView.isHidden = false
            firstHackLabel.text = "TABLE #\(String(describing: givenHacks["1"]!))"
        }
        if givenHacks["2"] != nil{
            nosecond = false
            secondHackView.isHidden = false
            secondHackLabel.text = "TABLE #\(String(describing: givenHacks["2"]!))"
        }
        if givenHacks["3"] != nil{
            nothird = false
            thirdHackView.isHidden = false
            thirdHackLabel.text = "TABLE #\(String(describing: givenHacks["3"]!))"
        }
    }
    
    
}

