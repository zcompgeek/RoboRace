//
//  Board.swift
//  RoboRace
//
//  Created by Zach Costa on 7/31/14.
//  Copyright (c) 2014 Zach Costa. All rights reserved.
//
import Foundation
import SpriteKit

let NumColumns = 12
let NumRows = 12

class Board {
    let tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)  // private
    let title: String!
    let difficulty: Int!
    let deck: Deck!
    let robots = Set<Robot>()
    var player: Robot!
    var startPoint : (column: Int, row: Int)!
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func botAtColumn(column: Int, row: Int) -> Robot? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        for bot in robots {
            if bot.column == column && bot.row == row { return bot }
        }
        return nil
    }
    

    
    //A. Execute Each Phase
        // 1. Sort Robot Cards by Priority
        // 2. Attempt to execute each robot's command in order
        // 3. Move Board Elements
        // 4. Resolve Laser Fire
    
    func executePhase(phaseNum: Int) {
        var order: [Robot] = []
        for bot in robots {
            order.append(bot)
        }
        order.sort {
            r1, r2 in r1.program[phaseNum]!.priority > r2.program[phaseNum]!.priority
        }
        
        for bot in order {
            if bot.state == RobotState.Normal {
                moveBot(bot, command: bot.program[phaseNum]!)
            }
        }
        
        
        //Laser Fire
        //resolveLaserFire()
    }
    
    func resolveLaserFire() {
        //Board Lasers
        for bot in robots {
            if let tile = tileAtColumn(bot.column, row: bot.row) {
                switch tile.laser {
                case .SingleVert,.SingleHorz,.OriginVert,.OriginHorz :
                    bot.damage++
                case .DoubleHorz,.DoubleVert,.OriginHorz2,.OriginVert2 :
                    bot.damage += 2
                case .TripleHorz,.TripleVert,.OriginVert3,.OriginHorz3 :
                    bot.damage += 3
                case .None :
                    break
                }
            }
        }
        //Bot Lasers
    }
    
    func angleToDir(angle: CGFloat) -> Direction {
        switch angle {
            //Facing Up
        case let x where x < 3.toRad() :
            return Direction.Up
            //Facing Left
        case let x where x > 87.toRad() && x < 93.toRad() :
           return Direction.Left
            //Facing Down
        case let x where x > 177.toRad() && x < 183.toRad() :
            return Direction.Down
            //Facing Right
        case let x where x > 267.toRad() && x < 273.toRad() :
            return Direction.Right
        default:
            return angleToDir(angle % 360)
        }
    }
    
    func newBotDirection(bot: Robot) {
        switch bot.rotateBy {
        case 90 :
            if let newDir = Direction.fromRaw((bot.direction.toRaw() + 90) % 360) { bot.direction = newDir }
        case -90 :
            if let newDir = Direction.fromRaw(bot.direction.toRaw() - 90) { bot.direction = newDir }
            else { bot.direction = .Right }
        case 180, -180 :
            switch bot.direction {
            case (.Up) :
                bot.direction = .Down
            case ( .Left) :
                bot.direction = .Right
            case (.Down) :
                bot.direction = .Up
            case (.Right) :
                bot.direction = .Left
            }
        case 0 :
            return
        default :
            println("error in calculating new direction")
            return
        }
    }
    
    func boardRotation(bot: Robot, currTile: Tile, nextTile: Tile) {
        switch nextTile.tileType {
        case .SlowBeltRight,.SlowBeltLeft,.SlowBelt,.FastBelt,.FastBeltLeft,.FastBeltRight :
            //println("testing \(currTile.column),\(currTile.row) and \(nextTile.column),\(nextTile.row)")
            switch (angleToDir(currTile.angle),angleToDir(nextTile.angle)) {
            case (.Up,.Left),(.Down,.Right),(.Left,.Down),(.Right,.Up) :
                bot.rotateBy = 90
            case (.Up,.Right),(.Down,.Left),(.Left,.Up),(.Right,.Down)  :
                bot.rotateBy = -90
            default :
                //println("Matching \(angleToDir(currTile.angle).toRaw()) and \(angleToDir(nextTile.angle).toRaw())")
                return
            }
        default :
        return
        }
        newBotDirection(bot)
        
    }
    
    func boardElements(part: Int) {
        // 0 - Express conveyor belts move one square.
        // 1 - Express conveyor belts move their second square of movement.
        // 1 - Normal conveyor belts move their first and only square.
        // 2 - Pushers push one square if active this register phase.
        // 3 - Gears turn 90 degrees.
        // 4 - Crushers crush if active this register phase.
        switch part {
        case 0 :
            for bot in robots {
                if let tile = tileAtColumn(bot.column, row: bot.row) {
                    switch tile.tileType {
                    case .FastBelt, .FastBeltLeft, .FastBeltRight :
                        switch angleToDir(tile.angle) {
                        case .Up :
                            validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row + 1 ))
                            if let nextTile = tileAtColumn(tile.column, row: tile.row + 1) {
                                boardRotation(bot, currTile: tile, nextTile: nextTile)
                            }
                        case .Left :
                            validateMove(bot, start: (bot.column, bot.row), end: ( bot.column - 1, bot.row))
                            if let nextTile = tileAtColumn(tile.column - 1, row: tile.row) {
                                boardRotation(bot, currTile: tile, nextTile: nextTile)
                            }
                        case .Down :
                            validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row - 1))
                            if let nextTile = tileAtColumn(tile.column, row: tile.row - 1) {
                                boardRotation(bot, currTile: tile, nextTile: nextTile)
                            }
                        case .Right:
                            validateMove(bot, start: (bot.column, bot.row), end: ( bot.column + 1, bot.row))
                            if let nextTile = tileAtColumn(tile.column + 1, row: tile.row) {
                                boardRotation(bot, currTile: tile, nextTile: nextTile)
                            }
                        default :
                            break
                        }
                    default:
                        break
                    }
                    
                }
            }
        case 1 :
            for bot in robots {
                if let tile = tileAtColumn(bot.column, row: bot.row) {
                    switch tile.tileType {
                    case .SlowBelt, .SlowBeltLeft, .SlowBeltRight,.FastBelt, .FastBeltLeft, .FastBeltRight :
                        switch angleToDir(tile.angle) {
                        case .Up :
                            validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row + 1 ))
                            if let nextTile = tileAtColumn(tile.column, row: tile.row + 1) {
                                boardRotation(bot, currTile: tile, nextTile: nextTile)
                            }
                        case .Left :
                            validateMove(bot, start: (bot.column, bot.row), end: ( bot.column - 1, bot.row))
                            if let nextTile = tileAtColumn(tile.column - 1, row: tile.row) {
                                boardRotation(bot, currTile: tile, nextTile: nextTile)
                            }
                        case .Down :
                            validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row - 1))
                            if let nextTile = tileAtColumn(tile.column, row: tile.row - 1) {
                                boardRotation(bot, currTile: tile, nextTile: nextTile)
                            }
                        case .Right:
                            validateMove(bot, start: (bot.column, bot.row), end: ( bot.column + 1, bot.row))
                            if let nextTile = tileAtColumn(tile.column + 1, row: tile.row) {
                                boardRotation(bot, currTile: tile, nextTile: nextTile)
                            }
                        default :
                            break
                        }
                    default:
                        break
                    }
                    
                }
            }
        case 2 :
            //pushers
            break
        case 3 :
            for bot in robots {
                if let tile = tileAtColumn(bot.column, row: bot.row) {
                    switch tile.tileType {
                    case .RotateCW :
                        bot.rotateBy = -90
                        newBotDirection(bot)
                    case .RotateCCW :
                        bot.rotateBy = 90
                        newBotDirection(bot)
                    default :
                        break
                    }
                }
            }
        case 4 :
            //crushers
            break
        default :
            break
        }
    }
    
    func moveBot(bot: Robot, command: Card) {
        println(command.cardType)
        switch command.cardType {
        case .Move1 :
            switch bot.direction {
            case (.Up) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row + 1 ))
            case (.Left) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column - 1, bot.row ))
            case (.Down) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row - 1 ))
            case (.Right) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column + 1, bot.row ))
            }
        case .Move2 :
            switch bot.direction {
            case ( .Up) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row + 2 ))
            case ( .Left) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column - 2, bot.row ))
            case ( .Down) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row - 2 ))
            case ( .Right) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column + 2, bot.row ))
            }
        case .Move3 :
            switch bot.direction {
            case ( .Up) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row + 3 ))
            case (.Left) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column - 3, bot.row ))
            case (.Down) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row - 3 ))
            case (.Right) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column + 3, bot.row ))
            }
        case .BackUp :
            switch bot.direction {
            case (.Up) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row - 1 ))
            case ( .Left) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column + 1, bot.row ))
            case (.Down) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column, bot.row + 1 ))
            case (.Right) :
                validateMove(bot, start: (bot.column, bot.row), end: ( bot.column - 1, bot.row ))
            }
        case .TurnLeft :
            bot.rotateBy = 90.0
        case .TurnRight :
            bot.rotateBy = -90.0
        case .UTurn :
            bot.rotateBy = 180.0
        default :
                println("Tried to move with an option card")
        }
        newBotDirection(bot)
    }
    
    func validateMove(bot: Robot, start: ( column: Int,  row: Int), end: ( column: Int , row: Int)) {
        
        //TODO: Implement interactions with other robots
        //Placeholder just moves robot to destination
        //Check tiles that bot will encounter
        var path : [Tile] = []
        let horz : Int = (end.column - start.column)
        let vert : Int = (end.row - start.row)
        var moveDir : Direction = bot.direction
        //Make a new "Direction" for the movement of bot to account for BackUp
        //Add tiles to path
        if (horz < 0) {
            moveDir = .Left
            var pathColumn = start.column
            while pathColumn >= end.column {
                if let tile = tiles[pathColumn--,start.row] {
                    path.append(tile)
                }
            }
        } else if (vert < 0) {
                moveDir = .Down
            var pathRow = start.row
            while pathRow >= end.row {
                if let tile = tiles[start.column,pathRow--] {
                    path.append(tile)
                }
            }
        } else if (horz > 0) {
                moveDir = .Right
            var pathColumn = start.column
            while pathColumn <= end.column {
                if let tile = tiles[pathColumn++,start.row] {
                    path.append(tile)
                }
            }
        } else if (vert > 0) {
                moveDir = .Up
            var pathRow = start.row
            while pathRow <= end.row {
                if let tile = tiles[start.column,pathRow++] {
                    path.append(tile)
                }
            }
        }
        
        for (index,tile) in enumerate(path) {
            //If bot will fall into pit, kill it
            if tile.tileType == TileType.Pit {
                bot.state = .PitDeath
                bot.column = tile.column
                bot.row = tile.row
                return
            }
            //If bot will cross over wall - stop it
            switch (tile.wall, moveDir) {
            case (.Top, .Up),(.Left,.Left),(.Bottom,.Down),(.Right,.Right),(.LTopLeft,.Up),(.LTopLeft,.Left),(.LTopRight,.Right),(.LTopRight,.Up),(.LBottomLeft,.Down),(.LBottomLeft,.Left),(.LBottomRight,.Down),(.LBottomRight,.Right) :
                bot.column = tile.column
                bot.row = tile.row
                return
            case (.Top, .Down),(.LTopLeft, .Down),(.LTopRight,.Down) :
                if index != 0 {
                    bot.column = tile.column
                    bot.row = tile.row + 1
                    return
                }
            case (.Bottom, .Up),(.LBottomLeft, .Up),(.LBottomRight,.Up) :
                if index != 0 {
                    bot.column = tile.column
                    bot.row = tile.row - 1
                    return
                }
            case (.Left, .Right),(.LTopLeft, .Right),(.LBottomLeft,.Right) :
                if index != 0 {
                    bot.column = tile.column - 1
                    bot.row = tile.row
                    return
                }
            case (.Right, .Left),(.LTopRight, .Left),(.LBottomRight,.Left) :
                if index != 0 {
                    bot.column = tile.column + 1
                    bot.row = tile.row
                    return
                }
            case (.BottomTop,.Up),(.BottomTop,.Down),(.LeftRight,.Left),(.LeftRight,.Right) :
                if bot.column == tile.column && bot.row == tile.row { return }
                switch (tile.wall, moveDir) {
                case (.BottomTop,.Up) :
                    bot.column = tile.column
                    bot.row = tile.row - 1
                    return
                case (.BottomTop,.Down) :
                    bot.column = tile.column
                    bot.row = tile.row + 1
                    return
                case (.LeftRight,.Left) :
                    bot.column = tile.column + 1
                    bot.row = tile.row
                    return
                case (.LeftRight,.Right) :
                    bot.column = tile.column - 1
                    bot.row = tile.row
                    return
                default :
                    continue
                }
            default :
                continue
            }
        }
        
        //If bot encounters another bot, recursively check that any encountered bots can be moved and move them amount necessary
        
        //If everything is fine
        bot.column = end.column
        bot.row = end.row
    }
    
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"] {
                for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
                    let tileRow = NumRows - row - 1
                    for (column, value) in enumerate(rowArray) {
                        if let tileType = TileType.fromRaw(value) {
                            tiles[column, tileRow] = Tile(column: column, row:tileRow, tileType: tileType)
                        }
                    }
                }
            if let tilesArray: AnyObject = dictionary["angles"] {
                for (row, rowArray) in enumerate(tilesArray as [[CGFloat]]) {
                    let angleRow = NumRows - row - 1
                    for (column, angle) in enumerate(rowArray) {
                        if let tile = tiles[column, angleRow] {
                            tile.angle = angle * pi / 180.0
                        }
                    }
                }
            }
                if let tilesArray: AnyObject = dictionary["walls"] {
                    for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
                        let wallRow = NumRows - row - 1
                        for (column, value) in enumerate(rowArray) {
                            if let tile = tiles[column, wallRow] {
                                if let wall = wallSide.fromRaw(value) {
                                    tile.wall = wall
                                }
                            }
                        }
                    }
                }
                if let tilesArray: AnyObject = dictionary["lasers"] {
                    for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
                        let laserRow = NumRows - row - 1
                        for (column, value) in enumerate(rowArray) {
                            if let tile = tiles[column, laserRow] {
                                if let laser = LaserType.fromRaw(value) {
                                    tile.laser = laser
                                }
                            }
                        }
                    }
                }
                
                title = (dictionary["boardTitle"] as NSString)
                difficulty = (dictionary["difficulty"] as NSNumber)
            }
        }
        deck = Deck(isOptionsDeck: false)
        deck.shuffle()
        deck.shuffle()
    }
}
