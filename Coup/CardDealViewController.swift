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
    @IBOutlet weak var cardDeck: UIImageView!
    
    var diceRollInfo = Array<String>()
    
    var card1 = Card(type: .none)
    var card2 = Card(type: .none)
    
    var cardZoomed = 0
    var cardCanZoom = false
    
    let cardMargin: CGFloat = 10
    
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
            UIView.transition(with: self.tblDiceRolls, duration: 0.25, options: .transitionCrossDissolve, animations: {
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
    
    func getCardFrame(withMargin cardMargin: CGFloat, atSide side: Int, withScale scale: CGFloat) -> CGRect
    {
        var size = CGSize(width: self.cardDeck.frame.width, height: self.cardDeck.frame.height)
        var origin = CGPoint()
        
        if side == 0
        {
            origin = CGPoint(x: cardMargin, y: self.view.frame.maxY-self.cardDeck.frame.height-cardMargin)
        }
        else if side == 1
        {
            origin = CGPoint(x: self.view.frame.maxX-self.cardDeck.frame.width-cardMargin, y: self.view.frame.maxY-self.cardDeck.frame.height-cardMargin)
        }
        else if side == 2
        {
            origin = CGPoint(x: self.view.center.x-(self.cardDeck.frame.width/2), y: self.view.center.y-(self.cardDeck.frame.height/2))
            size = CGSize(width: self.cardDeck.frame.width*scale, height: self.cardDeck.frame.height*scale)
        }
        
        return CGRect(origin: origin, size: size)
    }
    
    func animateCardDeal()
    {
        let myCards = self.cardDealManager.appDelegate.playerCards[self.cardDealManager.appDelegate.playerManager.peer]!
        self.card1 = myCards[0]
        self.card2 = myCards[1]
        
        self.card1.frame = self.cardDeck.bounds
        self.card2.frame = self.cardDeck.bounds
        
        self.card1.center = self.cardDeck.center
        self.card2.center = self.cardDeck.center
                    
        self.view.addSubview(self.card1)
        self.view.addSubview(self.card2)
        
        UIView.transition(with: self.card1, duration: 1, options: .curveEaseIn, animations: {
            self.card1.frame = self.getCardFrame(withMargin: self.cardMargin, atSide: 0, withScale: 1)
        }, completion: { (finishedTransition) in
            
            self.card1.flip()
            
            self.cardCanZoom = true
            
            if !finishedTransition
            {
                print("CoupGame-CardDealViewController: Error: card 1 could not glide")
            }
        })
        
        UIView.transition(with: self.card2, duration: 1, options: .curveEaseIn, animations: {
            self.card2.frame = self.getCardFrame(withMargin: self.cardMargin, atSide: 1, withScale: 1)
        }, completion: { (finishedTransition) in
            
            self.card2.flip()
            
            self.cardCanZoom = true
            
            if !finishedTransition
            {
                print("CoupGame-CardDealViewController: Error: card 2 could not glide")
            }
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if self.cardCanZoom
        {
            if self.cardZoomed == 0
            {
                if self.card1.frame.contains(touches.first!.location(in: self.view))
                {
                    self.animateCardZoom(card: self.card1)
                    
                    self.cardZoomed = 1
                }
                
                if self.card2.frame.contains(touches.first!.location(in: self.view))
                {
                    self.animateCardZoom(card: self.card2)
                    
                    self.cardZoomed = 2
                }
            }
            else
            {
                if cardZoomed == 1
                {
                    self.animateCardZoomOut(card: self.card1)
                }
                
                if cardZoomed == 2
                {
                    self.animateCardZoomOut(card: self.card2)
                }
            }
        }
    }
    
    func animateCardZoom(card: Card)
    {
        self.cardCanZoom = false
        
        let cardZoomScale: CGFloat = 1.5
        let cardDecriptionFontSize: CGFloat = 25
        let textViewAlpha: CGFloat = 0.8
        let iconMargin: CGFloat = 5
        let iconSize: CGFloat = 36
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 618
        
        self.view.addSubview(blurEffectView)
        
        self.view.bringSubview(toFront: card)
        
        UIView.transition(with: card, duration: 1, options: .curveEaseIn, animations: {
            card.frame.size.width = card.frame.size.width*cardZoomScale
            card.frame.size.height = card.frame.size.height*cardZoomScale
            card.center = self.view.center
        }, completion: { (finishedTransition) in
            
            self.cardCanZoom = true
            
            let actionTextView = UITextView()
            actionTextView.frame = CGRect(x: 0, y: 0, width: card.bounds.width, height: card.bounds.height/2)
            actionTextView.backgroundColor = UIColor.gray.withAlphaComponent(textViewAlpha)
            actionTextView.text = card.actionInfo()
            actionTextView.textAlignment = .center
            actionTextView.font = UIFont.systemFont(ofSize: cardDecriptionFontSize)
            actionTextView.textColor = UIColor.darkText
            actionTextView.tag = 391
            
            card.addSubview(actionTextView)
            
            let actionIcon = UIImageView(image: UIImage(named: "actionIcon"))
            actionIcon.frame = CGRect(x: iconMargin, y: card.bounds.midY-iconSize-iconMargin, width: iconSize, height: iconSize)
            actionIcon.tag = 815
            card.addSubview(actionIcon)
            
            let blockTextView = UITextView()
            blockTextView.frame = CGRect(x: 0, y: card.bounds.midY, width: card.bounds.width, height: card.bounds.height/2)
            blockTextView.backgroundColor = UIColor.gray.withAlphaComponent(textViewAlpha)
            
            blockTextView.text = card.blockInfo()
            blockTextView.textAlignment = .center
            blockTextView.font = UIFont.systemFont(ofSize: cardDecriptionFontSize)
            blockTextView.textColor = UIColor.darkText
            blockTextView.tag = 540
            
            card.addSubview(blockTextView)
            
            let blockIcon = UIImageView(image: UIImage(named: "blockIcon"))
            blockIcon.frame = CGRect(x: iconMargin, y: card.bounds.maxY-iconSize-iconMargin, width: iconSize, height: iconSize)
            blockIcon.tag = 316
            card.addSubview(blockIcon)
            
            if !finishedTransition
            {
                print("CoupGame-CardDealViewController: Error: card could not zoom")
            }
        })
    }
    
    func animateCardZoomOut(card: Card)
    {
        self.cardCanZoom = false
        
        card.viewWithTag(391)!.removeFromSuperview()
        card.viewWithTag(540)!.removeFromSuperview()
        
        card.viewWithTag(815)!.removeFromSuperview()
        card.viewWithTag(316)!.removeFromSuperview()
        
        UIView.transition(with: card, duration: 1, options: .curveEaseIn, animations: {
            card.frame = self.getCardFrame(withMargin: self.cardMargin, atSide: self.cardZoomed-1, withScale: 1)
        }, completion: { (finishedTransition) in
            
            self.cardZoomed = 0
            
            self.view.viewWithTag(618)!.removeFromSuperview()
            
            self.cardCanZoom = true
            
            if !finishedTransition
            {
                print("CoupGame-CardDealViewController: Error: card could not zoom")
            }
        })
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
