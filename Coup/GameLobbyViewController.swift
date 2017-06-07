//
//  GameLobbyViewController.swift
//  Coup
//
//  Created by jackson on 6/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameLobbyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MPCManagerDelegate
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var joinedPeers = [MCPeerID]()
    var foundPeers = [MCPeerID]()
    
    @IBOutlet weak var tblPeers: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.mpcManager.delegate = self
        
        self.appDelegate.mpcManager.browser.startBrowsingForPeers()
        self.appDelegate.mpcManager.advertiser.startAdvertisingPeer()
    }
    
    // MARK: UITableView related method implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section
        {
            case 0:
                return self.foundPeers.count
            case 1:
                return self.joinedPeers.count
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
                cell.textLabel?.text = "Found: " + foundPeers[indexPath.row].displayName
            case 1:
                cell.textLabel?.text = "Joined: " + joinedPeers[indexPath.row].displayName
            default:
                break
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    // MARK: Peer Delagate Calls
    
    func foundPeer(peerID: MCPeerID) {
        OperationQueue.main.addOperation { () -> Void in
            if !self.joinedPeers.contains(peerID)
            {
                self.foundPeers.append(peerID)
                self.tblPeers.reloadData()
            }
        }
        
        self.appDelegate.mpcManager.browser.invitePeer(peerID, to: self.appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }
    
    func lostPeer(peerID: MCPeerID) {
        OperationQueue.main.addOperation { () -> Void in
            if self.foundPeers.index(of: peerID) != nil
            {
                self.foundPeers.remove(at: self.foundPeers.index(of: peerID)!)
            }
            self.tblPeers.reloadData()
        }
    }
    
    func invitationWasReceived(fromPeer: String) {
        //Accept Invite Automatically
        //if !joinedPeers.contains(MCPeerID(displayName: fromPeer))
        //{
            print("Accepted Invitation From " + fromPeer)
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
        //}
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        //self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
        //self.appDelegate.mpcManager.browser.stopBrowsingForPeers()
        print("Connected With " + peerID.displayName)
        OperationQueue.main.addOperation { () -> Void in
            self.joinedPeers.append(peerID)
            if self.foundPeers.index(of: peerID) != nil
            {
                self.foundPeers.remove(at: self.foundPeers.index(of: peerID)!)
            }
            self.tblPeers.reloadData()
        }
    }
    
    @IBAction func refreshTable(_ sender: Any)
    {
        OperationQueue.main.addOperation { () -> Void in
            for peer in self.joinedPeers
            {
                if !self.appDelegate.mpcManager.session.connectedPeers.contains(peer)
                {
                    self.joinedPeers.remove(at: self.joinedPeers.index(of: peer)!)
                }
            }
            self.tblPeers.reloadData()
            
            self.foundPeers.removeAll()
            for peer in self.appDelegate.mpcManager.foundPeers
            {
                if !self.joinedPeers.contains(peer)
                {
                    self.foundPeers.append(peer)
                    self.tblPeers.reloadData()
                    
                    self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
                }
            }
        }
    }
}
