//
//  GameScene.swift
//  RoboRace
//
//  Created by Zach Costa on 7/31/14.
//  Copyright (c) 2014 Zach Costa. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var board: Board!
    
    let pi : CGFloat = 3.14159265359

    let TileWidth: CGFloat = 64.0
    let TileHeight: CGFloat = 64.0
    
    let cardWidth: Int = 85.0
    let cardHeight: Int = 140.0
    
    let gameLayer = SKNode()
    let tilesLayer = SKNode()
    let botLayer = SKNode()
    let displayLayer = SKNode()
    let laserSound = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    let deathSound = SKAction.playSoundFileNamed("death.wav", waitForCompletion: false)
    
    var selectedCard: SKSpriteNode!
    
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        var touch : UITouch = touches.anyObject() as UITouch
        var positionInScene : CGPoint = touch.locationInNode(self)
        selectNodeForTouch(positionInScene)
    }
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        
        if let touchedNode  = nodeAtPoint(touchLocation) as? SKSpriteNode {
            selectedCard = touchedNode
        } else {
            selectedCard = SKSpriteNode()
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        var touch: UITouch = touches.anyObject() as UITouch
        var positionInScene = touch.locationInNode(self)
        var previousPosition = touch.previousLocationInNode(self)
        var translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y)
        if let name = selectedCard.name {
            let position = selectedCard.position
            if name.isEqual("Card") {
                selectedCard.position = CGPointMake(position.x + translation.x, position.y + translation.y)
            }
        }
        
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        var touch: UITouch = touches.anyObject() as UITouch
        var positionInScene = touch.locationInNode(displayLayer)
        for i in 1..<6 {
            if let slot = displayLayer.childNodeWithName("Slot\(i)") {
                if slot.containsPoint(positionInScene) {
                    if let name = selectedCard.name {
                        if name.isEqual("Card") {
                            selectedCard.position = slot.position
                            for card in board.player.hand {
                                if let sprite = card.sprite {
                                    if sprite.isEqual(selectedCard) {
                                        board.player.program[i - 1] = card
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
            
        }
        selectedCard = SKSpriteNode()
    }
    
    func degToRad(degree: Float) -> CGFloat {
        return CGFloat(degree) * pi / CGFloat(180.0)
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func animateBotMoves(completion: () -> ()) {
        for bot in board.robots {
            let sprite = bot.sprite
            let moveTo = pointForColumn(bot.column, row: bot.row)
            let spritePoint = convertPoint(sprite.position)
            let delta = NSTimeInterval(max(abs(bot.column - spritePoint.column), abs(bot.row - spritePoint.row)))
            var Duration = 0.5 * delta
            if Duration == 0.0 && bot.rotateBy != 0 { Duration = 0.5}
            let move = SKAction.moveTo(moveTo, duration: Duration)
            let rotate = SKAction.rotateByAngle(degToRad(bot.rotateBy), duration: Duration)
            move.timingMode = .EaseOut
            rotate.timingMode = .EaseOut
            sprite.runAction(SKAction.group([move,rotate]))
            runAction(SKAction.waitForDuration(Duration + 0.001), completion: completion)
            bot.rotateBy = 0.0
            //runAction(swapSound)
        }
    }
    
    func animateBotCarnage() {
        for bot in board.robots {
            if bot.state == RobotState.PitDeath {
                let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                scaleAction.timingMode = .EaseOut
                bot.sprite.runAction(SKAction.group([deathSound,scaleAction])) {bot.sprite.hidden = true}
                bot.state = RobotState.Destroyed
            }
        }
        runAction(SKAction.waitForDuration(0.3))
    }
    
    func displayHand() {
        var sprites = [SKSpriteNode]()
        for (index, card) in enumerate(board.player.hand) {
            let cardSprite = SKSpriteNode(imageNamed: card.cardType.spriteName)
            cardSprite.position = CGPoint(x: Int(TileWidth) * 3, y: -cardHeight)
            cardSprite.name = "Card"
            let cardLabel = SKLabelNode(text: "\(card.priority)")
            cardLabel.position = CGPoint(x: 0, y: 45)
            cardLabel.fontSize = 10
            cardLabel.fontName = "GillSans"
            cardLabel.fontColor = UIColor(red: 116.0/255.0, green: 169.0/255.0, blue: 123.0/255.0, alpha: 1.0)
            cardSprite.addChild(cardLabel)
            displayLayer.addChild(cardSprite)
            card.sprite = cardSprite
            sprites.append(cardSprite)
        }
        
        for (index, sprite) in enumerate(sprites) {
            var moveTo = CGPoint()
            if index == 0 {
                moveTo = CGPoint(x: Int(TileWidth) * 3 + cardWidth * index, y: -cardHeight/2)
            } else {
                moveTo = CGPoint(x: Int(TileWidth) * 3 + (cardWidth + 5) * index - (cardWidth / 3) * index , y: -cardHeight/2)
            }
            let delay = 0.5 + NSTimeInterval(index) * 0.1
            let move = SKAction.moveTo(moveTo, duration: delay)
            move.timingMode = .EaseOut
            sprite.runAction( SKAction.sequence([SKAction.waitForDuration(delay),move]))
        }
        let Duration = NSTimeInterval(0.5 + 9 * 0.2)
        runAction(SKAction.waitForDuration(Duration))
        
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = board.tileAtColumn(column, row: row) {
                    var tileNode =  SKSpriteNode()
                    var tileSkin: SKSpriteNode!
                    if tile.tileType ==  TileType.Normal {
                        var i = Int(arc4random_uniform(3)) + 1
                        tileSkin = SKSpriteNode(imageNamed: "Normal\(i)")
                    } else {
                        tileSkin = SKSpriteNode(imageNamed: tile.tileType.spriteName)
                    }
                    tileNode.position = pointForColumn(column, row: row)
                    tileSkin.zRotation = tile.angle
                    tileNode.addChild(tileSkin)
                    if tile.laser != .None {
                        var laser = SKSpriteNode(imageNamed: "Laser")
                        switch tile.laser {
                        case .OriginHorz :
                            laser.zRotation = 270 * pi / 180
                        case .OriginVert :
                            break
                        case .SingleHorz :
                            laser = SKSpriteNode(imageNamed: "Single")
                            laser.zRotation = 90 * pi / 180
                        case .SingleVert :
                            laser = SKSpriteNode(imageNamed: "Single")
                        case .DoubleVert :
                            laser = SKSpriteNode(imageNamed: "Single")
                            var laser2 = SKSpriteNode(imageNamed: "Single")
                            laser.position = CGPoint(x: -15, y: 0)
                            laser2.position = CGPoint(x: 15, y: 0)
                            tileNode.addChild(laser2)
                        case .DoubleHorz :
                            laser = SKSpriteNode(imageNamed: "Single")
                            var laser2 = SKSpriteNode(imageNamed: "Single")
                            laser.zRotation = 90 * pi / 180
                            laser2.zRotation = 90 * pi / 180
                            laser.position = CGPoint(x: 0, y: 15)
                            laser2.position = CGPoint(x: 0, y: -15)
                            tileNode.addChild(laser2)
                        case .TripleHorz :
                            laser = SKSpriteNode(imageNamed: "Single")
                            var laser2 = SKSpriteNode(imageNamed: "Single")
                            var laser3 = SKSpriteNode(imageNamed: "Single")
                            laser.zRotation = 90 * pi / 180
                            laser2.zRotation = 90 * pi / 180
                            laser3.zRotation = 90 * pi / 180
                            laser.position = CGPoint(x: 0, y: 20)
                            laser3.position = CGPoint(x: 0, y: -20)
                            tileNode.addChild(laser2)
                            tileNode.addChild(laser3)
                        case .TripleVert :
                            laser = SKSpriteNode(imageNamed: "Single")
                            var laser2 = SKSpriteNode(imageNamed: "Single")
                            var laser3 = SKSpriteNode(imageNamed: "Single")
                            laser2.position = CGPoint(x: -20, y: 0)
                            laser3.position = CGPoint(x: 20, y: 0)
                            tileNode.addChild(laser2)
                            tileNode.addChild(laser3)
                        case .OriginHorz2 :
                            var laser2 = SKSpriteNode(imageNamed: "Laser")
                            laser.zRotation = 270 * pi / 180
                            laser2.zRotation = 270 * pi / 180
                            laser.position = CGPoint(x: 0, y: 15)
                            laser2.position = CGPoint(x: 0, y: -15)
                            tileNode.addChild(laser2)
                        case .OriginVert2 :
                            var laser2 = SKSpriteNode(imageNamed: "Laser")
                            laser.position = CGPoint(x: 5, y: 0)
                            laser2.position = CGPoint(x: -5, y: 0)
                            tileNode.addChild(laser2)
                        case .OriginHorz3 :
                            var laser2 = SKSpriteNode(imageNamed: "Laser")
                            var laser3 = SKSpriteNode(imageNamed: "Laser")
                            laser.zRotation = 270 * pi / 180
                            laser2.zRotation = 270 * pi / 180
                            laser3.zRotation = 270 * pi / 180
                            laser.position = CGPoint(x: 0, y: 20)
                            laser2.position = CGPoint(x: 0, y: 0)
                            laser3.position = CGPoint(x: 0, y: -20)
                            tileNode.addChild(laser2)
                            tileNode.addChild(laser3)
                        case .OriginVert3 :
                            var laser2 = SKSpriteNode(imageNamed: "Laser")
                            var laser3 = SKSpriteNode(imageNamed: "Laser")
                            laser.position = CGPoint(x: 20, y: 0)
                            laser2.position = CGPoint(x: 0, y: 0)
                            laser3.position = CGPoint(x: -20, y: 0)
                            tileNode.addChild(laser3)
                        case .None :
                            break
                        }
                        tileNode.addChild(laser)
                        
                    }
                    if tile.wall != .None {
                        var wall = SKSpriteNode(imageNamed: "Wall")
                        switch tile.wall {
                        case .Top :
                            wall.position = CGPoint (x: 0.0, y: 27.0)
                        case .Left :
                            wall.position = CGPoint (x: -27, y:0)
                            wall.zRotation = 90 * pi / 180
                        case .Right :
                            wall.position = CGPoint (x: 28, y:0)
                            wall.zRotation = 90 * pi / 180
                        case .Bottom :
                            wall.position = CGPoint (x: 0.0, y: -27.0)
                        case .LBottomLeft :
                            wall = SKSpriteNode(imageNamed: "LWall")
                        case .LBottomRight :
                            wall = SKSpriteNode(imageNamed: "LWall")
                            wall.zRotation = 90 * pi / 180
                        case .LTopRight :
                            wall = SKSpriteNode(imageNamed: "LWall")
                            wall.zRotation = 180 * pi / 180
                        case .LTopLeft :
                            wall = SKSpriteNode(imageNamed: "LWall")
                            wall.zRotation = 270 * pi / 180
                        case .LeftRight :
                            var wall2 = SKSpriteNode(imageNamed: "Wall")
                            wall.position = CGPoint (x: -27, y:0)
                            wall.zRotation = 90 * pi / 180
                            wall2.position = CGPoint (x: 28, y: 0)
                            wall2.zRotation = 90 * pi / 180
                            tileNode.addChild(wall2)
                        case .BottomTop :
                            var wall2 = SKSpriteNode(imageNamed: "Wall")
                            wall.position = CGPoint (x: 0, y: -27)
                            wall2.position = CGPoint (x: 0, y: 27)
                            tileNode.addChild(wall2)
                        default :
                            wall.position = CGPoint (x:0,y:0)
                        }
                        tileNode.addChild(wall)
                    }
                    
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }

    func addDisplay() {
        for i in 1..<6 {
            let cardSlotNode = SKSpriteNode(imageNamed: "CardSlot")
            cardSlotNode.position = CGPoint(x: cardWidth + (cardWidth + 20) * i, y: cardHeight - 20)
            cardSlotNode.name = "Slot\(i)"
            let slotLabel = SKLabelNode(text: "\(i)")
            slotLabel.fontColor = UIColor(red: 116.0/255.0, green: 169.0/255.0, blue: 123.0/255.0, alpha: 1.0)
            slotLabel.fontName = "GillSans-UltraBold"
            slotLabel.fontSize = 36
            cardSlotNode.addChild(slotLabel)
            displayLayer.addChild(cardSlotNode)
        }
    }
    
    func addBots() {
        for bot in board.robots {
            let botNode = SKSpriteNode(imageNamed: bot.robotName.spriteName)
            bot.column = board.startPoint.column
            bot.row = board.startPoint.row
            bot.spawnPoint = board.startPoint
            botNode.position = pointForColumn(bot.column, row: bot.row)
            botNode.zRotation = bot.direction.toRaw() * pi / 180.0
            bot.sprite = botNode
            botLayer.addChild(botNode)
        }
    }
    
    init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode()
        background.color = .blackColor()
        addChild(background)
        
        addChild(gameLayer)
        //gameLayer.hidden = true
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2 + TileHeight*2)
        
        let displayLayerPosition =
        CGPoint(
            x: -CGFloat(6)*TileWidth + cardWidth/2,
            y: -CGFloat(6)*TileHeight - cardHeight/2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        botLayer.position = layerPosition
        gameLayer.addChild(botLayer)
        
        displayLayer.position = displayLayerPosition
        gameLayer.addChild(displayLayer)
        
        selectedCard = SKSpriteNode()
    }
}