//
//  Card.swift
//  RoboRace
//
//  Created by Zach Costa on 8/1/14.
//  Copyright (c) 2014 Zach Costa. All rights reserved.
//

import SpriteKit

enum CardType: Int, Printable {
    case Option = 1, Move1, Move2, Move3, BackUp, TurnLeft, TurnRight, UTurn
    
    var CardNames: String {
    let cardNames = [
        "Option",
        "Move 1",
        "Move 2",
        "Move 3",
        "Back Up",
        "Turn Left",
        "Turn Right",
        "U Turn" ]
        
        return cardNames[toRaw() - 1]
        
    }
    
    var spriteName: String {
    let spriteNames = [
        "Option",
        "Move1",
        "Move2",
        "Move3",
        "Backup",
        "TurnLeft",
        "TurnRight",
        "UTurn" ]
        
        return spriteNames[toRaw() - 1]
        
    }
    var description: String {
        return CardNames
    }
}

//Card Priority
// 0 - 100 = UTurn
// 100 - 400 = TurnLeft and TurnRight
// 400 - 500 = Backup
// 500 - 600 = Move 1
// 600 - 700 = Move 2
// 700 - 800 = Move 3

class Card: Hashable {
    let cardType: CardType
    let priority: Int
    let desc: String?
    let title: String?
    var sprite: SKSpriteNode!
    
    init(_ title: String, _ desc: String){
        self.priority = 0
        self.cardType = CardType.Option
        self.title = title
        self.desc = desc
    }
    
    init(cardType: CardType, priority: Int) {
        self.cardType = cardType
        self.priority = priority
        self.title = nil
        self.desc = nil
    }
    
    var hashValue: Int {
        return priority * cardType.toRaw()
    }
    
    //var description: String {
    //    if cardType == CardType.Option { return "type: Option title: \(title) description \(desc)" }
      //  else {
        //    return "type: \(cardType) priority: \(priority)"}
    //}
}

func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs.priority == rhs.priority && lhs.cardType == rhs.cardType
}