//
//  Card.swift
//  Coup
//
//  Created by jackson on 6/10/17.
//  Copyright © 2017 jackson. All rights reserved.
//

import UIKit

class Card: UIImageView
{
    enum CardType: Int
    {
        case none
        case duke
        case assassin
        case ambassador
        case captain
        case contessa
    }
    
    var cardType: CardType!
    var flipped = false
    
    init(type: Int)
    {
        super.init(image: UIImage(named: "cardBack"))
        
        self.cardType = CardType(rawValue: type)!
        
        self.image = UIImage(named: "cardBack")
    }
    
    init(type: CardType)
    {
        super.init(image: UIImage(named: "cardBack"))
        
        self.cardType = type
        
        self.image = UIImage(named: "cardBack")
    }
    
    func getImage() -> UIImage
    {
        var imageName = String()
        switch self.cardType
        {
            case .duke:
                imageName = "cardJack"
            case .assassin:
                imageName = "cardAce"
            case .ambassador:
                imageName = "card10"
            case .captain:
                imageName = "cardKing"
            case .contessa:
                imageName = "cardQueen"
            case .none:
                break
            default:
                break
        }
        
        return UIImage(named: imageName)!
    }
    
    func actionInfo() -> String
    {
        switch self.cardType
        {
            case .duke:
                return "Tut: Can take 3 tokens from the pile"
            case .assassin:
                return "Assassinate: Can kill one player's card at a cost of 3 tokens"
            case .ambassador:
                return "Exchange: Put ambassador back in the deck, draw 2 cards, and choose one to keep"
            case .captain:
                return "Steal: Take 2 tokens from another player"
            case .contessa:
                return "None"
            case .none:
                return ""
            default:
                return ""
        }
    }
    
    func blockInfo() -> String
    {
        switch self.cardType
        {
            case .duke:
                return "Blocks all players from using foreign aid"
            case .assassin:
                return "None"
            case .ambassador:
                return "Blocks players from stealing your tokens"
            case .captain:
                return "Blocks players from stealing your tokens"
            case .contessa:
                return "Blocks assassination"
            case .none:
                return ""
            default:
                return ""
        }
    }
    
    func flip()
    {
        if !flipped
        {
            self.image = getImage()
        }
        else
        {
            self.image = UIImage(named: "cardBack")
        }
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(cardType.rawValue, forKey: "cardType")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.cardType = CardType(rawValue: aDecoder.decodeInteger(forKey: "cardType"))!
    }
}
