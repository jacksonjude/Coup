//
//  DiceRollTableViewController.swift
//  Coup
//
//  Created by jackson on 6/17/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DiceRollTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var diceRollInfo: Array<String>! = []
    @IBOutlet weak var tblDiceRolls: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableView), name: Notification.Name(rawValue: "reloadDiceRollTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideDiceRollTableView), name: Notification.Name(rawValue: "hideDiceRollTable"), object: nil)
    }
    
    @objc func reloadTableView(notification: Notification)
    {
        self.diceRollInfo = notification.object as! Array<String>
        
        self.tblDiceRolls.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func hideDiceRollTableView()
    {
        OperationQueue.main.addOperation { () -> Void in
            UIView.transition(with: self.tblDiceRolls, duration: 2, options: .curveEaseInOut, animations: {
                self.tblDiceRolls.frame = CGRect(x: 0, y: -400, width: self.tblDiceRolls.frame.width, height: self.tblDiceRolls.frame.height)
            }, completion: { (finishedTransition) in
                self.tblDiceRolls.isHidden = true
                
                
                if !finishedTransition
                {
                    print("CoupGame-DiceRollTableViewController: Error: tblDiceRolls could not fade out")
                }
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diceRollInfo.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellDiceRoll", for: indexPath) as UITableViewCell
        cell.textLabel?.text = diceRollInfo[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
