//
//  CardDealViewController.swift
//  Coup
//
//  Created by jackson on 6/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class CardDealViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var cardDealManager: CardDealManager!
    
    @IBOutlet weak var tblDiceRolls: UITableView!
    @IBOutlet weak var dealCardsButton: UIButton!
    
    var diceRollInfo = Array<String>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.disableDealButton()
        
        self.cardDealManager = CardDealManager(viewController: self)
    }
    
    //MARK: Player Ordering
    
    func displayDiceRoll(peerName: MCPeerID, roll: Int)
    {
        let diceRoll = String(roll) + " - " + peerName.displayName
        
        diceRollInfo.append(diceRoll)
        
        OperationQueue.main.addOperation { () -> Void in
            self.tblDiceRolls.reloadData()
        }
    }
    
    @IBAction func rollDiceButtonPressed(_ sender: Any)
    {
        self.cardDealManager.rollDice()
        if sender is UIButton
        {
            let rollDiceButton = sender as! UIButton
            rollDiceButton.isEnabled = false
        }
    }
    
    func hideDiceRollTableView()
    {
        OperationQueue.main.addOperation { () -> Void in
            UIView.transition(with: self.tblDiceRolls, duration: 2, options: .transitionCrossDissolve, animations: {
                self.tblDiceRolls.isHidden = true
            }, completion: { (finishedTransition) in
                if !finishedTransition
                {
                    print("CoupGame-CardDealViewController: Error: tblDiceRolls could not fade out")
                }
            })
        }
    }
    
    //MARK: Card Deal
    
    func enableDealButton()
    {
        OperationQueue.main.addOperation { () -> Void in
            self.dealCardsButton.isEnabled = true
        }
    }
    
    func disableDealButton()
    {
        OperationQueue.main.addOperation { () -> Void in
            self.dealCardsButton.isEnabled = false
        }
    }
    
    @IBAction func dealCardsButtonPressed(_ sender: Any)
    {
        self.cardDealManager.dealCardsButtonPressed()
    }
    
    //MARK: UITableView related method implementation
    
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
