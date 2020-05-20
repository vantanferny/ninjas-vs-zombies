//
//  Environment.swift
//  ninjas-vs-zombies
//
//  Created by Anferny Vanta on 5/9/20.
//  Copyright © 2020 Anferny Vanta. All rights reserved.
//

import Foundation
import SpriteKit

class Environment {
    var elements : Array<SKNode> = []

    init(size : CGSize) {
        initFloor(size: size)
        initWalls(size: size)
        initBackground(size: size)
        initCrates(size: size)
        initUpperGround(size: size)
    }

    func initFloor(size: CGSize) {
        let floor : SKSpriteNode = SKSpriteNode()
        floor.position = CGPoint(x: size.width, y: 0)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 160))
        floor.physicsBody?.isDynamic = false

        floor.physicsBody?.categoryBitMask = Physics.physicalBodies.floor.rawValue
        floor.physicsBody?.collisionBitMask = Physics.physicalBodies.player.rawValue + Physics.physicalBodies.zombie.rawValue
        
        // tiles
        
        let tileSize = CGSize(width: 40, height: 40)
        let tileLength : Int = 40

        let horizontalStart : Int = -Int(size.width) + (tileLength / 2)
        let columnCount: Int = (Int(size.width * 2) / tileLength)
        
        let bottomTileYPosition: Int = (tileLength / 2)
        let topTileYPosition: Int = bottomTileYPosition + tileLength

        for count in 0...columnCount {
            let bottomTile = SKSpriteNode(imageNamed: "tile_0")
            bottomTile.size = tileSize
            bottomTile.position = CGPoint(x: horizontalStart + (tileLength * count), y: bottomTileYPosition)
            floor.addChild(bottomTile)

            let topTile = SKSpriteNode(imageNamed: "tile_1")
            topTile.size = tileSize
            topTile.position = CGPoint(x: horizontalStart + (tileLength * count), y: topTileYPosition)
            floor.addChild(topTile)
        }
        
        elements.append(floor)
    }
    
    func initWalls(size: CGSize) {
        let leftWall = SKSpriteNode()
        leftWall.position = CGPoint(x: 0 - 5, y: size.height / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: size.height))
        leftWall.physicsBody?.isDynamic = false

        let rightWall = SKSpriteNode()
        rightWall.position = CGPoint(x: (size.width * 2) + 5, y: size.height / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: size.height))
        rightWall.physicsBody?.isDynamic = false
        
        elements.append(leftWall)
        elements.append(rightWall)
    }
    
    func initBackground(size: CGSize) {
        let startingPoint = size.width / 2
        let widthMargin = size.width

        for count in 0...1 {
            let background = SKSpriteNode(imageNamed: "bg_night")
            background.size = size
            background.position = CGPoint(x: startingPoint + (CGFloat(count) * widthMargin), y: size.height / 2)
            background.zPosition = -1

            elements.append(background)
        }
    }
    
    func initCrates(size: CGSize) {
        let crateOne = SKSpriteNode(imageNamed: "crate")
        crateOne.position = CGPoint(x: size.width * (2/3), y: 105)
        
        let crateTwo = SKSpriteNode(imageNamed: "crate")
        crateTwo.position = CGPoint(x: size.width * (4/3), y: 105)

        let crates = [
            crateOne,
            crateTwo,
        ]
        
        let crateSize : CGSize = CGSize(width: 50, height: 50)

        for crate in crates {
            crate.size = crateSize
            crate.physicsBody = SKPhysicsBody(rectangleOf: crateSize)
            crate.physicsBody?.isDynamic = false
            crate.physicsBody?.categoryBitMask = Physics.physicalBodies.floor.rawValue
            
            elements.append(crate)
        }
    }
    
    func initUpperGround(size: CGSize) {
        let upperGround = SKNode()
        upperGround.position = CGPoint(x: size.width * 1.7, y: size.height * (3/5))

        let upperGroundTileCount = 8
        let tileLength : Int = 40

        upperGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upperGroundTileCount * tileLength, height: tileLength))
        upperGround.physicsBody?.isDynamic = false
        
        upperGround.physicsBody?.categoryBitMask = Physics.physicalBodies.floor.rawValue

        var upperGroundTiles : Array<SKSpriteNode> = []
        let upperGroundTileSize : CGSize = CGSize(width: tileLength, height: tileLength)

        let upperGroundLeft = SKSpriteNode(imageNamed: "tile_2a")
        upperGroundTiles.append(upperGroundLeft)

        let upperGroundMidTileCount : Int = upperGroundTileCount - 2
        for _ in 1...upperGroundMidTileCount {
            let upperGroundMid = SKSpriteNode(imageNamed: "tile_2b")

            upperGroundTiles.append(upperGroundMid)
        }

        let upperGroundRight = SKSpriteNode(imageNamed: "tile_2c")
        upperGroundTiles.append(upperGroundRight)

        var tileCount = 1
        let startingPoint = -((upperGroundTileCount / 2) * tileLength) - (tileLength / 2)
        for tile in upperGroundTiles {
            tile.size = upperGroundTileSize
            tile.position = CGPoint(x: startingPoint + (tileCount * tileLength), y: 0)

            upperGround.addChild(tile)

            tileCount += 1
        }
        
        elements.append(upperGround)
    }
}

