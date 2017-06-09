//
//  CardDealManager.swift
//  Coup
//
//  Created by jackson on 6/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class CardDealManager: NSObject
{
    var diceRoll: Int!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var playerDiceRolls = Dictionary<Int,MCPeerID>()
    var viewController: CardDealViewController!
    
    var playerOrder = Array<MCPeerID>()
    
    init(viewController: CardDealViewController)
    {
        super.init()
        
        self.viewController = viewController
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.receivedDiceRoll), name: Notification.Name(rawValue: "receivedDiceRoll"), object: nil)
    }
    
    func rollDice()
    {
        self.diceRoll = Int(arc4random_uniform(12) + 1) //0-11 random + 1
        
        //Pack diceRolls into dictionary
        var diceRollDictionary = Dictionary<String, AnyObject>()
        diceRollDictionary.updateValue("diceRoll" as AnyObject, forKey: "message")
        diceRollDictionary.updateValue(diceRoll as AnyObject, forKey: "roll")
        
        self.playerDiceRolls.updateValue(appDelegate.mpcManager.peer, forKey: self.diceRoll)
        
        print("CoupGame-CardDealManager: You rolled a " + String(self.diceRoll))
        viewController.displayDiceRoll(peerName: appDelegate.mpcManager.peer, roll: self.diceRoll)
        
        if !appDelegate.mpcManager.sendData(dictionaryWithData: diceRollDictionary) //Send the data and handle any errors
        {
            print("CoupGame-CardDealManager: Error: diceRoll Data could not be sent")
        }
        
        if self.playerDiceRolls.values.count == appDelegate.mpcManager.acceptedPeers.count+1
        {
            self.findPlayerOrder()
        }
    }
    
    @objc func receivedDiceRoll(notification: Notification)
    {
        //Unpack receivedDiceRollDictionary into peerID and roll
        let receivedDiceRollDictionary = notification.object as! Dictionary<String,AnyObject>
        let peerID = receivedDiceRollDictionary["peerID"] as! MCPeerID
        let receivedDiceRoll = receivedDiceRollDictionary["roll"] as! Int
        
        //Add the peerID and roll to diceRoll array
        self.playerDiceRolls.updateValue(peerID, forKey: receivedDiceRoll)
        
        //print to log and display dice roll on table view
        print("CoupGame-CardDealManager: " + peerID.displayName + " rolled a " + String(receivedDiceRoll))
        viewController.displayDiceRoll(peerName: peerID, roll: receivedDiceRoll)
        
        //If all peers have rolled plus self, determine dealer and player order by highest dice roll to lowest dice roll
        if self.playerDiceRolls.values.count == appDelegate.mpcManager.acceptedPeers.count+1
        {
            self.findPlayerOrder()
        }
    }
    
    func findPlayerOrder()
    {
        //Until player order contains all peers + self
        while self.playerOrder.count != self.appDelegate.mpcManager.acceptedPeers.count+1
        {
            //Add the highest diceRoll player to the player order
            self.playerOrder.append(self.playerDiceRolls[self.playerDiceRolls.keys.max()!]!)
            //And remove the value for the next player
            self.playerDiceRolls.removeValue(forKey: self.playerDiceRolls.keys.max()!)
        }
        
        print("CoupGame-CardDealManager: playerOrder is:" + String(describing: playerOrder))
        
        print("CoupGame-CardDealManager:" + playerOrder.first!.displayName + " is the dealer")
        
        
        UIView.transition(with: self.viewController.tblDiceRolls, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.viewController.tblDiceRolls.isHidden = true
        }, completion: { (finishedTransition) in
            if !finishedTransition
            {
                print("CoupGame-CardDealManager: Error: tblDiceRolls could not fade out")
            }
        })
        
        if playerOrder.first == appDelegate.mpcManager.peer
        {
            self.dealCards()
        }
    }
    
    func dealCards()
    {
        
    }
}
