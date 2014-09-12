//
//  Tile.swift
//  CookieCrunch
//
//  Created by Zach Costa on 7/28/14.
//  Copyright (c) 2014 Zach Costa. All rights reserved.
//
import SpriteKit

enum TileType: Int, Printable {
    case Unknown = 0,  Normal, //1
                     SlowBelt, //2
                 SlowBeltLeft, //3
                SlowBeltRight, //4
                     FastBelt, //5
                 FastBeltLeft, //6
                FastBeltRight, //7
                          Pit, //8
                       Wrench, //9
                 DoubleWrench, //10
                        Laser, //11
                       Pusher, //12
                      Crusher, //13
                     RotateCW, //14
                    RotateCCW  //15
    var spriteName: String {
    let spriteNames = [
        "Normal",
        "SlowBelt",
        "SlowBeltLeft",
        "SlowBeltRight",
        "FastBelt",
        "FastBeltLeft",
        "FastBeltRight",
        "Pit",
        "Wrench",
        "DoubleWrench",
        "Laser",
        "Pusher",
        "Crusher",
        "RotateCW",
        "RotateCCW"]
        
        return spriteNames[toRaw() - 1]
    }
    
    var description: String {
        return spriteName
    }
}

enum wallSide: Int {
    case None = 0,
              Bottom, //1
                 Top, //2
                Left, //3
                Right, //4
          LBottomLeft, //5
          LBottomRight, //6
          LTopLeft,  //7
            LTopRight,  //8
           BottomTop,  //9
            LeftRight  //10
}


//Laser Origins are always on the bottom or Left
enum LaserType: Int {
    case None = 0,
           OriginVert, //1
           OriginHorz, //2
           SingleVert, //3
           SingleHorz, //4
           DoubleVert, //5
           DoubleHorz, //6
           TripleVert, //7
           TripleHorz, //8
          OriginVert2, //9
          OriginHorz2, //10
          OriginVert3, //11
          OriginHorz3  //12
}


class Tile: Printable, Hashable {
    var column: Int
    var row: Int
    let tileType: TileType
    var angle: CGFloat
    var flag: Int?
    var wall: wallSide
    var laser: LaserType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, tileType: TileType) {
        self.column = column
        self.row = row
        self.tileType = tileType
        self.angle = 0
        self.laser = LaserType.None
        self.wall = wallSide.None
    }
    
    var description: String {
    return "type:\(tileType) angle: \(angle) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
    return row*10 + column
    }
}

func ==(lhs: Tile, rhs: Tile) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}