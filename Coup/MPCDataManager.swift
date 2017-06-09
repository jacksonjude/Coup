//
//  MPCDataManager.swift
//  Coup
//
//  Created by jackson on 6/7/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class MPCDataManager: NSObject
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override init()
    {
        super.init()
    }
    
    func receivedData(_ data: Data, fromPeer peerID: MCPeerID)
    {
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,AnyObject>
        let message = dataDictionary["message"]! as! String
        
        switch message
        {
            case "startGame":
                NotificationCenter.default.post(name: Notification.Name(rawValue: "startGame"), object: nil)
            case "diceRoll":
                let diceRoll = dataDictionary["roll"]! as! Int
            
                var receivedDiceRollDictionary = Dictionary<String,AnyObject>()
                receivedDiceRollDictionary.updateValue(diceRoll as AnyObject, forKey: "roll")
                receivedDiceRollDictionary.updateValue(peerID, forKey: "peerID")
            
                NotificationCenter.default.post(name: Notification.Name(rawValue: "receivedDiceRoll"), object: receivedDiceRollDictionary)
            default:
                break
        }
    }
}
