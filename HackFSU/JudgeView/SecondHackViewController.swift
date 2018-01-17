//
//  SecondHackViewController.swift
//  judgeViewTesting
//
//  Created by Andres Ibarra on 1/12/18.
//  Copyright © 2018 Andres Ibarra. All rights reserved.
//

import UIKit

class SecondHackViewController: UIViewController {

    @IBOutlet var superlativesTableView: UITableView!
    @IBOutlet var addSuperlativeButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var tableDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableDescriptionLabel.text = "Go To Table #\(String(describing: givenHacks["2"]!))"
        
        //positioning everything correctly
        tableDescriptionLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/4)
        superlativesTableView.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        
        addSuperlativeButton.layer.position = CGPoint(x: self.view.bounds.width/2, y: (3*self.view.bounds.height)/4)
        nextButton.layer.position =  CGPoint(x: self.view.bounds.width/2, y: ((addSuperlativeButton.bounds.height)+(3*self.view.bounds.height)/4)+10)
        
        
        superlativesTableView.delegate = self
        superlativesTableView.dataSource = self
        superlativesTableView.layer.isHidden = true
        
        superlativesTableView.layer.cornerRadius = 30.0
        superlativesTableView.layer.masksToBounds = true
        
        addSuperlativeButton.layer.cornerRadius = 30.0
        addSuperlativeButton.layer.masksToBounds = true
        
        nextButton.layer.cornerRadius = 30.0
        nextButton.layer.masksToBounds = true
        
        
    }
    
    
    @IBAction func clickedAddSuperlative(_ sender: Any) {
        superlativesTableView.reloadData()
        superlativesTableView.layer.isHidden = false
    }
    
    @IBAction func selectedSuperlative(_ sender: UIButton) {
        if sender.image(for: UIControlState()) == #imageLiteral(resourceName: "circle-tick-7"){
            //already selected so unselect and remove from superlatives dictionary
            superlatives[givenHacks["2"]!] = nil
            sender.setImage(#imageLiteral(resourceName: "plus-simple-7"), for: UIControlState())
            
        }else{
            let cells = superlativesTableView.visibleCells as! [superlativeTableViewCell]
            
            for cell in cells{
                if cell.addButton.image(for: UIControlState()) == #imageLiteral(resourceName: "circle-tick-7"){
                    cell.addButton.setImage(#imageLiteral(resourceName: "plus-simple-7"), for: UIControlState())
                }
            }
            sender.setImage(#imageLiteral(resourceName: "circle-tick-7"), for: UIControlState())
            for cell in cells{
                if cell.addButton.image(for: UIControlState()) == #imageLiteral(resourceName: "circle-tick-7"){
                    if let sText =  cell.superlative.text{
                        superlatives[givenHacks["2"]!] = sText
                    }
                }
            }
            
        }
    
    }
    
    
    @IBAction func clickedNext(_ sender: Any) {
        if nothird{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FinalRankingView")
            self.present(vc!, animated: true, completion: nil)
            
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ThirdHackView")
            self.present(vc!, animated: true, completion: nil)
            
        }
        
        
    }
    

}

extension SecondHackViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return superlativeOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "superlativeCells") as! superlativeTableViewCell
        
        cell.cellView.layer.cornerRadius = 10.0
        cell.cellView.layer.masksToBounds = true
        
        cell.superlative.text = superlativeOptions[indexPath.row]
        return cell
    }
    
    
    
    
    
}

