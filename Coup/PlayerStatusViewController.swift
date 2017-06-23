//
//  PlayerStatusViewController.swift
//  Coup
//
//  Created by jackson on 6/19/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PlayerStatusViewController: UIViewController
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var peer: MCPeerID?
    
    @IBOutlet weak var card1: UIImageView!
    @IBOutlet weak var card2: UIImageView!
    @IBOutlet weak var coinCount: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if peer == nil
        {
            peer = appDelegate.playerManager.peer
            card1.image = appDelegate.playerCards[peer!]![0].getImage()
            card2.image = appDelegate.playerCards[peer!]![1].getImage()
        }
        else
        {
            card1.image = appDelegate.playerCards[peer!]![0].getImage()
            card2.image = appDelegate.playerCards[peer!]![1].getImage()
        }
    }
    
    func updateStatus()
    {
        self.coinCount.text = "\(appDelegate.playerCoins[peer!]!) coins"
        
        if appDelegate.playerCards[peer!]!.count == 1
        {
            self.card2.isHidden = true
        }
        
        if appDelegate.playerCards[peer!]!.count == 0
        {
            self.card1.isHidden = true
            self.card2.isHidden = true
        }
    }
}
