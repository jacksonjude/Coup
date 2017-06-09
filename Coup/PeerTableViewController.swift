//
//  PeerTableViewController.swift
//  Coup
//
//  Created by jackson on 6/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PeerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlayerManagerDelegate
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tblPeers: UITableView!
    
    var foundPeersOnTable = Array<MCPeerID>()
    var acceptedPeersOnTable = Array<MCPeerID>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NotificationCenter.default.addObserver(self, selector:#selector(self.startGameFromPeerMessage), name: Notification.Name(rawValue: "startGame"), object: nil)
        
        self.foundPeersOnTable = appDelegate.playerManager.foundPeers
        
        appDelegate.playerManager.delegate = self
        
        appDelegate.playerManager.browser.startBrowsingForPeers()
        appDelegate.playerManager.advertiser.startAdvertisingPeer()
    }
    
    // MARK: UITableView related method implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section
        {
            case 0:
                return self.foundPeersOnTable.count
            case 1:
                return self.acceptedPeersOnTable.count
            default:
                return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellPeer", for: indexPath) as UITableViewCell
        switch indexPath.section
        {
            case 0:
                cell.textLabel?.text = "Found: " + self.foundPeersOnTable[indexPath.row].displayName
            case 1:
                cell.textLabel?.text = "Joined: " + self.acceptedPeersOnTable[indexPath.row].displayName
            default:
                break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section
        {
            case 0:
                return "Found Peers"
            case 1:
                return "Joined Peers"
            default:
                return "Peers"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //Invite the peer when selected
        print("CoupGame-GameLobbyViewController: Inviting " + appDelegate.playerManager.foundPeers[indexPath.row].displayName)
        appDelegate.playerManager.browser.invitePeer(appDelegate.playerManager.foundPeers[indexPath.row], to: appDelegate.playerManager.session, withContext: nil, timeout: 20)
    }
    
    @IBAction func refreshTable(_ sender: Any)
    {
        OperationQueue.main.addOperation { () -> Void in
            self.tblPeers.reloadData()
        }
    }
    
    // MARK: Peer Delagate Calls
    
    func foundPeer(peerID: MCPeerID)
    {
        //If the peer is not already on the table, add it
        if !self.foundPeersOnTable.contains(peerID)
        {
            self.foundPeersOnTable.append(peerID)
        }
        
        OperationQueue.main.addOperation { () -> Void in
            self.tblPeers.reloadData()
        }
    }
    
    func lostPeer(peerID: MCPeerID)
    {
        //If the peer is on the table, remove it
        if self.foundPeersOnTable.contains(peerID)
        {
            self.foundPeersOnTable.remove(at: foundPeersOnTable.index(of: peerID)!)
        }
        
        OperationQueue.main.addOperation { () -> Void in
            self.tblPeers.reloadData()
        }
    }
    
    func invitationWasReceived(fromPeer: String)
    {
        //Accept by default
        print("CoupGame-GameLobbyViewController: Accepting Invitation from " + fromPeer)
        appDelegate.playerManager.invitationHandler(true, appDelegate.playerManager.session)
    }
    
    func connectedWithPeer(peerID: MCPeerID)
    {
        print("CoupGame-GameLobbyViewController: Connected With " + peerID.displayName)
        
        //If the peer was on the "found" section, remove it, and add it to the accepted section if not already added
        if self.foundPeersOnTable.contains(peerID)
        {
            self.foundPeersOnTable.remove(at: foundPeersOnTable.index(of: peerID)!)
        }
        
        if !self.acceptedPeersOnTable.contains(peerID)
        {
            self.acceptedPeersOnTable.append(peerID)
        }
        
        OperationQueue.main.addOperation { () -> Void in
            self.tblPeers.reloadData()
        }
    }
    
    //MARK: Segue to CardDealView
    @IBAction func startGameButtonPressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "startingGame", sender: self)
        
        var startGameDictionary = Dictionary<String,AnyObject>()
        startGameDictionary.updateValue("startGame" as AnyObject, forKey: "message")
        if !appDelegate.playerManager.sendData(dictionaryWithData: startGameDictionary)
        {
            print("CoupGame-PeerTableViewController: Error: startGame message could not be sent")
        }
    }
    
    @objc func startGameFromPeerMessage()
    {
        OperationQueue.main.addOperation { () -> Void in
            self.performSegue(withIdentifier: "startingGame", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "startingGame"
        {
            //Any setup before starting game...
        }
    }
}
