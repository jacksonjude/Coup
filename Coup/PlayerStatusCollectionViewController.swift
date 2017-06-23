//
//  PlayerStatusCollectionView.swift
//  Coup
//
//  Created by jackson on 6/19/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PlayerStatusCollectionViewController: UICollectionViewController
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.playerManager.acceptedPeers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "idCellPlayerStatus", for: indexPath)
        var cellFrame = CGRect()
        cellFrame.size = self.view.frame.size
        cell.frame = cellFrame
        
        let playerStatusViewController = self.storyboard!.instantiateViewController(withIdentifier: "playerStatus") as! PlayerStatusViewController
        playerStatusViewController.peer = appDelegate.playerManager.acceptedPeers[indexPath.row]
        playerStatusViewController.view.frame = cell.bounds
        
        cell.addSubview(playerStatusViewController.view)
        self.addChildViewController(playerStatusViewController)
        
        return cell
    }
}
