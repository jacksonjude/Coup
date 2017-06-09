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
    var cardDealViewController: CardDealViewController!
    
    var playerOrder = Array<MCPeerID>()
    
    var myPeerID: MCPeerID!
    var playerCount: Int!
    
    init(viewController: CardDealViewController)
    {
        super.init()
        
        self.cardDealViewController = viewController
        
        self.myPeerID = appDelegate.playerManager.peer
        self.playerCount = appDelegate.playerManager.acceptedPeers.count+1
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.receivedDiceRoll), name: Notification.Name(rawValue: "receivedDiceRoll"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.dealCards), name: Notification.Name(rawValue: "dealCards"), object: nil)
    }
    
    //MARK: Player Ordering
    
    func rollDice()
    {
        self.diceRoll = Int(arc4random_uniform(12) + 1) //0-11 random + 1
        
        //Pack diceRolls into dictionary
        var diceRollDictionary = Dictionary<String, AnyObject>()
        diceRollDictionary.updateValue("diceRoll" as AnyObject, forKey: "message")
        diceRollDictionary.updateValue(diceRoll as AnyObject, forKey: "roll")
        
        self.playerDiceRolls.updateValue(myPeerID, forKey: self.diceRoll)
        
        print("CoupGame-CardDealManager: You rolled a " + String(self.diceRoll))
        cardDealViewController.displayDiceRoll(peerName: myPeerID, roll: self.diceRoll)
        
        if !appDelegate.playerManager.sendData(dictionaryWithData: diceRollDictionary) //Send the data and handle any errors
        {
            print("CoupGame-CardDealManager: Error: diceRoll Data could not be sent")
        }
        
        if self.playerDiceRolls.values.count == playerCount
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
        cardDealViewController.displayDiceRoll(peerName: peerID, roll: receivedDiceRoll)
        
        //If all peers have rolled plus self, determine dealer and player order by highest dice roll to lowest dice roll
        if self.playerDiceRolls.values.count == playerCount
        {
            self.findPlayerOrder()
        }
    }
    
    func findPlayerOrder()
    {
        //Until player order contains all peers + self
        while self.playerOrder.count != playerCount
        {
            //Add the highest diceRoll player to the player order
            self.playerOrder.append(self.playerDiceRolls[self.playerDiceRolls.keys.max()!]!)
            //And remove the value for the next player
            self.playerDiceRolls.removeValue(forKey: self.playerDiceRolls.keys.max()!)
        }
        
        print("CoupGame-CardDealManager: playerOrder is:" + String(describing: playerOrder))
        print("CoupGame-CardDealManager: " + playerOrder.first!.displayName + " is the dealer")
        
        appDelegate.playerOrder = self.playerOrder
        
        self.cardDealViewController.enableDealButton()
    }
    
    //MARK: Card Deal
    
    func dealCardsButtonPressed()
    {
        self.dealCards()
        
        var dealCardsDictionary = Dictionary<String,AnyObject>()
        dealCardsDictionary.updateValue("dealCards" as AnyObject, forKey: "message")
        if !appDelegate.playerManager.sendData(dictionaryWithData: dealCardsDictionary)
        {
            print("CoupGame-CardDealManager: Error: Deal Cards message could not be sent")
        }
    }
    
    @objc func dealCards()
    {
        self.cardDealViewController.disableDealButton()
        self.cardDealViewController.hideDiceRollTableView()
        
        if appDelegate.playerOrder.first == myPeerID
        {
            
        }
    }
}
