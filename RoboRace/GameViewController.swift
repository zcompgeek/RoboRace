//
//  GameViewController.swift
//  RoboRace
//
//  Created by Zach Costa on 7/31/14.
//  Copyright (c) 2014 Zach Costa. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var board: Board!
    
    @IBOutlet var phaseNum: UILabel!
    @IBOutlet var dealButton: UIButton!
    @IBOutlet var damageCount: UILabel!
    
    
    //var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .AllButUpsideDown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        board = Board(filename: "Board_0")
        scene.board = board
        scene.addTiles()
        scene.addDisplay()
        
        board.startPoint = (6,0)
        

        
        // Present the scene.
        skView.presentScene(scene)
        
        
        // Load and start background music.
        //let url = NSBundle.mainBundle().URLForResource("Mining by Moonlight", withExtension: "mp3")
        //backgroundMusic = AVAudioPlayer(contentsOfURL: url, error: nil)
        //backgroundMusic.numberOfLoops = -1
        //backgroundMusic.play()
        
        //Start the game by adding sprites
        beginGame()
    }
    
    @IBAction func dealButtonPressed(_: AnyObject) {
        dealCards()
    }
    
    @IBAction func beginButtonPressed(_: AnyObject) {
        var isFull = true
        for card in board.player.program {
            (isFull = isFull && card != nil)
        }
        if isFull {
            executeTurn(0)
        }
    }

    
    func findRobot(toFind: RobotName) -> Robot? {
        for bot in board.robots {
            if bot.robotName == toFind {return bot}
        }
        return nil
    }
    
    func beginGame() {
        
        //Select player robot
        board.player = Robot(name: "Ball Bot", bot: .BallBot)
            
            
        board.robots.insert(board.player)

        scene.addBots()
    }
    
    let prog = [Card(cardType: .Move1, priority: 0),Card(cardType:.Move2, priority: 0),Card(cardType: .TurnLeft, priority: 0),
                                Card(cardType: .BackUp, priority: 0),Card(cardType: .UTurn, priority: 0)]
    
    func updatePhaseDisplay(phase: Int) {
        phaseNum.text = "PHASE \(phase + 1)"
    }
    
    func updateDamageDisplay(damage: Int) {
        damageCount.text = "DAMAGE: \(damage)"
    }
    
    func dealCards() {
        dealButton.hidden = true
        for bot in board.robots {
            var hand = [Card]()
            for _ in 0..<9 {
                hand.append(board.deck.draw()!)
            }
            hand.sortInPlace() {
                c1, c2 in c1.priority < c2.priority
            }
            bot.hand = hand
        }
        scene.displayHand()
    }
    
    func boardElements(part: Int, completion: ()->()) {
        if part == 5 {completion()}
        
        board.boardElements(part)
        scene.animateBotMoves() {
            self.boardElements(part + 1, completion: completion)
        }
    }
    
    func executeTurn(phase: Int) {
        if phase == 5 {return}
        
        updatePhaseDisplay(phase)
        board.executePhase(phase)
        scene.animateBotMoves() {
            self.scene.animateBotCarnage()
            self.boardElements(0) {
                self.board.resolveLaserFire()
                self.updateDamageDisplay(self.board.player.damage)
                for bot in self.board.robots {
                    if (bot.state == RobotState.PitDeath || bot.state == RobotState.Destroyed) && bot.lives == 0 {
                        self.board.robots.remove(bot)
                    }
                }
                self.executeTurn(phase + 1)
            }
        }
        
        
    

    }
    

}
