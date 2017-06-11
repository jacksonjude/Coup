//
//  CardDealManager.swift
//  Coup
//
//  Created by jackson on 6/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import GameplayKit

class CardDealManager: NSObject
{
    var diceRoll: Int!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var playerDiceRolls = Dictionary<MCPeerID,Int>()
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
        NotificationCenter.default.addObserver(self, selector:#selector(self.handleReceivedPlayerCards), name: Notification.Name(rawValue: "receivedPlayerCards"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Player Ordering
    
    func rollDice()
    {
        self.diceRoll = Int(arc4random_uniform(12) + 1) //0-11 random + 1
        
        //Pack diceRolls into dictionary
        var diceRollDictionary = Dictionary<String, AnyObject>()
        diceRollDictionary.updateValue("diceRoll" as AnyObject, forKey: "message")
        diceRollDictionary.updateValue(diceRoll as AnyObject, forKey: "roll")
        
        self.playerDiceRolls.updateValue(self.diceRoll, forKey: myPeerID)
        
        print("CoupGame-CardDealManager: You rolled a " + String(self.diceRoll))
        cardDealViewController.displayDiceRoll(peerName: myPeerID, roll: self.diceRoll)
        
        if !appDelegate.playerManager.sendData(dictionaryWithData: diceRollDictionary, toPeers: appDelegate.playerManager.acceptedPeers) //Send the data and handle any errors
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
        self.playerDiceRolls.updateValue(receivedDiceRoll, forKey: peerID)
        
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
            let highestPlayerKey = findKeyForValue(value: self.playerDiceRolls.values.max()!, dictionary: self.playerDiceRolls)!
            
            self.playerOrder.append(highestPlayerKey)
            //And remove the value for the next player
            self.playerDiceRolls.removeValue(forKey: highestPlayerKey)
        }
        
        print("CoupGame-CardDealManager: playerOrder is:" + String(describing: playerOrder))
        print("CoupGame-CardDealManager: " + playerOrder.first!.displayName + " is the dealer")
        
        appDelegate.playerOrder = self.playerOrder
        
        self.cardDealViewController.enableDealButton()
    }
    
    func findKeyForValue(value: Int, dictionary: Dictionary<MCPeerID, Int>) -> MCPeerID?
    {
        for key in dictionary.keys
        {
            if value == dictionary[key]
            {
                return key
            }
        }
        
        return nil
    }
    
    //MARK: Card Deal
    
    func dealCardsButtonPressed()
    {
        var dealCardsDictionary = Dictionary<String,AnyObject>()
        dealCardsDictionary.updateValue("dealCards" as AnyObject, forKey: "message")
        
        if !appDelegate.playerManager.sendData(dictionaryWithData: dealCardsDictionary, toPeers: self.appDelegate.playerManager.acceptedPeers)
        {
            print("CoupGame-CardDealManager: Error: Could not send deal cards message")
        }
        
        self.dealCards()
    }
    
    @objc func dealCards()
    {
        self.cardDealViewController.disableDealButton()
        self.cardDealViewController.hideDiceRollTableView()
        
        if appDelegate.playerOrder.first == myPeerID
        {
            var masterDeck: [Card] = []
            let cardAmount = 4
            var cardsAdded = 0
            while cardAmount != cardsAdded
            {
                masterDeck.append(Card(type: .ambassador))
                masterDeck.append(Card(type: .assassin))
                masterDeck.append(Card(type: .captain))
                masterDeck.append(Card(type: .contessa))
                masterDeck.append(Card(type: .duke))
                
                cardsAdded += 1
            }
            //let masterDeck = [Card(type: .ambassador), Card(type: .ambassador), Card(type: .ambassador), Card(type: .ambassador), Card(type: .ambassador), Card(type: .assassin), Card(type: .assassin), Card(type: .assassin), Card(type: .assassin), Card(type: .assassin), Card(type: .captain), Card(type: .captain), Card(type: .captain), Card(type: .captain), Card(type: .captain), Card(type: .contessa), Card(type: .contessa), Card(type: .contessa), Card(type: .contessa), Card(type: .contessa), Card(type: .duke), Card(type: .duke), Card(type: .duke), Card(type: .duke), Card(type: .duke)]
            
            var shuffledMasterDeck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: masterDeck)
            
            for player in appDelegate.playerOrder
            {
                let playerCards = [shuffledMasterDeck[0], shuffledMasterDeck[1]]
                
                var playerCardsDictionary = Dictionary<String,AnyObject>()
                playerCardsDictionary.updateValue("playerCards" as AnyObject, forKey: "message")
                playerCardsDictionary.updateValue(playerCards as AnyObject, forKey: "cards")
                playerCardsDictionary.updateValue(player as AnyObject, forKey: "player")
                
                if !appDelegate.playerManager.sendData(dictionaryWithData: playerCardsDictionary, toPeers: appDelegate.playerManager.acceptedPeers)
                {
                    print("CoupGame-CardDealManager: Error: Player Cards could not be sent")
                }
                
                appDelegate.playerCards.updateValue(playerCards as! [Card], forKey: player)
                self.cardDealViewController.animateCardDeal()
                
                shuffledMasterDeck.remove(at: 0)
                shuffledMasterDeck.remove(at: 0)
            }
        }
    }
    
    @objc func handleReceivedPlayerCards(notification: Notification)
    {
        OperationQueue.main.addOperation { () -> Void in
            let receivedPlayerCards = notification.object as! Dictionary<String,AnyObject>
            let player = receivedPlayerCards["player"] as! MCPeerID
            let cards = receivedPlayerCards["cards"] as! [Card]
            
            self.appDelegate.playerCards.updateValue(cards, forKey: player)
            
            print("CoupGame-CardDealManager: " + player.displayName + "'s cards received: [" + String(describing: cards[0].cardType) + ", " + String(describing: cards[1].cardType) + "]")
            
            if player == self.appDelegate.playerManager.peer
            {
                self.cardDealViewController.animateCardDeal()
            }
        }
    }
}
