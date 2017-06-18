//
//  CardDealViewController.swift
//  Coup
//
//  Created by jackson on 6/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class CardDealViewController: UIViewController
{
    var cardDealManager: CardDealManager!
    var diceRollTableViewController: DiceRollTableViewController!
    
    @IBOutlet weak var dealCardsButton: UIButton!
    @IBOutlet weak var cardDeck: UIImageView!
    @IBOutlet weak var continueToGameButton: UIButton!
    
    var diceRollInfo = Array<String>()
    
    var card1: UIImageView!
    var card2: UIImageView!
    
    var myCards: Array<Card>!
    
    var cardZoomed = 0
    var cardCanZoom = false
    
    let cardMargin: CGFloat = 10
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.disableDealButton()
        
        self.continueToGameButton.isHidden = true
        self.continueToGameButton.isEnabled = false
        
        self.cardDealManager = CardDealManager(viewController: self)
    }
    
    //MARK: Player Ordering
    
    func displayDiceRoll(peerName: MCPeerID, roll: Int)
    {
        let diceRoll = String(roll) + " - " + peerName.displayName
        
        diceRollInfo.append(diceRoll)
        
        OperationQueue.main.addOperation { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadDiceRollTable"), object: self.diceRollInfo)
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideDiceRollTable"), object: self.diceRollInfo)
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
    
    func flipCard(cardImageView: UIImageView, card: Card)
    {
        if !card.flipped
        {
            cardImageView.image = card.getImage()
        }
        else
        {
            cardImageView.image = UIImage(named: "cardBack")
        }
    }
    
    func animateCardDeal()
    {
        self.myCards = self.cardDealManager.appDelegate.playerCards[self.cardDealManager.appDelegate.playerManager.peer]!
        self.card1 = UIImageView(image: UIImage(named: "cardBack"))
        self.card2 = UIImageView(image: UIImage(named: "cardBack"))
        
        self.card1.frame = self.cardDeck.bounds
        self.card2.frame = self.cardDeck.bounds
        
        self.card1.center = self.cardDeck.center
        self.card2.center = self.cardDeck.center
                    
        self.view.addSubview(self.card1)
        self.view.addSubview(self.card2)
        
        UIView.transition(with: self.card1, duration: 3, options: .curveEaseInOut, animations: {
            self.card1.frame = self.getCardFrame(withMargin: self.cardMargin, atSide: 0, withScale: 1)
        }, completion: { (finishedTransition) in
            
            self.flipCard(cardImageView: self.card1, card: self.myCards[0])
            
            self.cardCanZoom = true
            
            if !finishedTransition
            {
                print("CoupGame-CardDealViewController: Error: card 1 could not glide")
            }
        })
        
        UIView.transition(with: self.card2, duration: 3, options: .curveEaseInOut, animations: {
            self.card2.frame = self.getCardFrame(withMargin: self.cardMargin, atSide: 1, withScale: 1)
        }, completion: { (finishedTransition) in
            
            self.flipCard(cardImageView: self.card2, card: self.myCards[1])
            
            self.cardCanZoom = true
            
            self.continueToGameButton.isHidden = false
            self.continueToGameButton.isEnabled = true
            
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
                    self.animateCardZoom(cardImageView: self.card1, card: self.myCards[0])
                    
                    self.cardZoomed = 1
                }
                
                if self.card2.frame.contains(touches.first!.location(in: self.view))
                {
                    self.animateCardZoom(cardImageView: self.card2, card: self.myCards[1])
                    
                    self.cardZoomed = 2
                }
            }
            else
            {
                if cardZoomed == 1
                {
                    self.animateCardZoomOut(cardImageView: self.card1, card: self.myCards[0])
                }
                
                if cardZoomed == 2
                {
                    self.animateCardZoomOut(cardImageView: self.card2, card: self.myCards[1])
                }
            }
        }
    }
    
    func animateCardZoom(cardImageView: UIImageView, card: Card)
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
        
        self.view.bringSubview(toFront: cardImageView)
        
        UIView.transition(with: cardImageView, duration: 1, options: .curveEaseInOut, animations: {
            cardImageView.frame.size.width = cardImageView.frame.size.width*cardZoomScale
            cardImageView.frame.size.height = cardImageView.frame.size.height*cardZoomScale
            cardImageView.center = self.view.center
        }, completion: { (finishedTransition) in
            
            self.cardCanZoom = true
            
            let actionTextView = UITextView()
            actionTextView.frame = CGRect(x: 0, y: 0, width: cardImageView.bounds.width, height: cardImageView.bounds.height/2)
            actionTextView.backgroundColor = UIColor.gray.withAlphaComponent(textViewAlpha)
            
            actionTextView.text = card.actionInfo()
            actionTextView.textAlignment = .center
            actionTextView.font = UIFont.systemFont(ofSize: cardDecriptionFontSize)
            actionTextView.textColor = UIColor.darkText
            actionTextView.isEditable = false
            actionTextView.tag = 391
            
            cardImageView.addSubview(actionTextView)
            
            let actionIcon = UIImageView(image: UIImage(named: "actionIcon"))
            actionIcon.frame = CGRect(x: iconMargin, y: cardImageView.bounds.midY-iconSize-iconMargin, width: iconSize, height: iconSize)
            actionIcon.tag = 815
            cardImageView.addSubview(actionIcon)
            
            let blockTextView = UITextView()
            blockTextView.frame = CGRect(x: 0, y: cardImageView.bounds.midY, width: cardImageView.bounds.width, height: cardImageView.bounds.height/2)
            blockTextView.backgroundColor = UIColor.gray.withAlphaComponent(textViewAlpha)
            
            blockTextView.text = card.blockInfo()
            blockTextView.textAlignment = .center
            blockTextView.font = UIFont.systemFont(ofSize: cardDecriptionFontSize)
            blockTextView.textColor = UIColor.darkText
            blockTextView.isEditable = false
            blockTextView.tag = 540
            
            cardImageView.addSubview(blockTextView)
            
            let blockIcon = UIImageView(image: UIImage(named: "blockIcon"))
            blockIcon.frame = CGRect(x: iconMargin, y: cardImageView.bounds.maxY-iconSize-iconMargin, width: iconSize, height: iconSize)
            blockIcon.tag = 316
            cardImageView.addSubview(blockIcon)
            
            if !finishedTransition
            {
                print("CoupGame-CardDealViewController: Error: card could not zoom")
            }
        })
    }
    
    func animateCardZoomOut(cardImageView: UIImageView, card: Card)
    {
        self.cardCanZoom = false
        
        cardImageView.viewWithTag(391)!.removeFromSuperview()
        cardImageView.viewWithTag(540)!.removeFromSuperview()
        
        cardImageView.viewWithTag(815)!.removeFromSuperview()
        cardImageView.viewWithTag(316)!.removeFromSuperview()
        
        UIView.transition(with: cardImageView, duration: 1, options: .curveEaseInOut, animations: {
            cardImageView.frame = self.getCardFrame(withMargin: self.cardMargin, atSide: self.cardZoomed-1, withScale: 1)
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
    
    @IBAction func continueToGameButtonPressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "presentGameDisplay", sender: self)
    }
}
