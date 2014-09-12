//
//  Robot.swift
//  RoboRace
//
//  Created by Zach Costa on 8/1/14.
//  Copyright (c) 2014 Zach Costa. All rights reserved.
//
import Foundation
import SpriteKit

enum RobotName: Int, Printable {
    case Unknown = 0, BallBot
    var spriteName: String {
    let spriteNames = [
        "Robot1"]
        
        return spriteNames[toRaw() - 1]
    }
    
    var description: String {
    return spriteName
    }
}

enum RobotState: Int {
    case Normal = 0, PitDeath, Destroyed
}

class Robot: Hashable {
    let name: String
    let robotName: RobotName
    var state: RobotState
    var damage: Int
    var lives: Int
    var options: Set<Card>
    var hand: [Card]
    var program: [Card?]
    var column: Int!
    var row: Int!
    var direction: Direction
    var rotateBy: Float
    var sprite: SKSpriteNode!
    var spawnPoint: (column: Int, row: Int)!
    
    
    init(name: String, bot: RobotName){
        self.name = name
        robotName = bot
        damage = 0
        lives = 3
        options = Set<Card>()
        program = [nil,nil,nil,nil,nil]
        hand = []
        direction = .Up
        rotateBy = 0.0
        state = .Normal
    }
    
    func programRegisters(ph1: Card, _ ph2: Card, _ ph3: Card, _ ph4: Card, _ ph5: Card) {
        program = [ph1,ph2,ph3,ph4,ph5]
    }
    
    var hashValue: Int {
        if let hash = name.toInt() {return hash}
        return 0
    }
}

func ==(lhs: Robot, rhs: Robot) -> Bool {
    return lhs.name == rhs.name
}