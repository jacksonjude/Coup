//
//  ViewController.swift
//  Coup
//
//  Created by jackson on 6/5/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "startingSearch"
        {
            //Any setup before starting game search...
            appDelegate.connectionState = 1
        }
    }
    
    @IBAction func joinGameButtonPressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "startingSearch", sender: self)
    }
    
    @IBAction func exitGameView(_ segue: UIStoryboardSegue)
    {
        NSLog("Exiting Game...")
        if segue.source is GameLobbyViewController
        {
            appDelegate.mpcManager.browser.stopBrowsingForPeers()
            appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
            appDelegate.mpcManager.acceptedPeers = []
            appDelegate.mpcManager.foundPeers = []
            appDelegate.mpcManager.session.disconnect()
        }
    }
}

