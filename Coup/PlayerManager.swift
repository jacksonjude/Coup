//
//  PlayerManager.swift
//  Coup
//
//  Created by jackson on 6/6/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol PlayerManagerDelegate {
    func foundPeer(peerID: MCPeerID)
    
    func lostPeer(peerID: MCPeerID)
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}

class PlayerManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate
{
    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    var acceptedPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    var delegate: PlayerManagerDelegate?
    
    override init()
    {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer, securityIdentity: nil,
                            encryptionPreference: .none)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "coup-game")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "coup-game")
        advertiser.delegate = self
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        print("CoupGame-PlayerManager: Found Peer!")
        
        delegate?.foundPeer(peerID: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated()
        {
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
        
        delegate?.lostPeer(peerID: peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("CoupGame-PlayerManager: " + error.localizedDescription)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(fromPeer: peerID.displayName)        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("CoupGame-PlayerManager: " + error.localizedDescription)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state
        {
        case MCSessionState.connected:
            print("CoupGame-PlayerManager: Connected to session: \(session)")
            
            self.acceptedPeers.append(peerID)
            delegate?.connectedWithPeer(peerID: peerID)
        case MCSessionState.connecting:
            print("CoupGame-PlayerManager: Connecting to session: \(session)")
            
        default:
            print("CoupGame-PlayerManager: Did not connect to session: \(session)")
            //Re-Invite if connection fails
            self.browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 20)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.handleReceivedData(data, fromPeer: peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    /*func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }*/
    
    func sendData(dictionaryWithData dictionary: Dictionary<String,AnyObject>) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        
        do
        {
            try session.send(dataToSend, toPeers: self.acceptedPeers, with: MCSessionSendDataMode.reliable)
        }
        catch
        {
            print("CoupGame-PlayerManager: Error: Data failed to send")
        }
        
        return true
    }
    
    func handleReceivedData(_ data: Data, fromPeer peerID: MCPeerID)
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
            case "dealCards":
                NotificationCenter.default.post(name: Notification.Name(rawValue: "dealCards"), object: nil)
            default:
                break
        }
    }
    
    func clearPlayerManagerData()
    {
        self.browser.stopBrowsingForPeers()
        self.advertiser.stopAdvertisingPeer()
        
        self.acceptedPeers.removeAll()
        
        self.session.delegate = nil
        self.session.disconnect()
    }
}
