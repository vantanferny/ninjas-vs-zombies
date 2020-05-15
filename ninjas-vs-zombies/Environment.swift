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
    var floor : SKSpriteNode!
    var leftWall : SKSpriteNode!
    var rightWall : SKSpriteNode!
    var crateOne : SKSpriteNode!
    var crateTwo : SKSpriteNode!
    
    var background : SKSpriteNode!
    var backgroundTwo : SKSpriteNode!

    init(size : CGSize) {
        initFloor(size: size)
        initWalls(size: size)
        initBackground(size: size)
        initCrates(size: size)
    }
    
    func initFloor(size: CGSize) {
        floor = SKSpriteNode()
        floor.position = CGPoint(x: size.width, y: 0)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 160))
        floor.physicsBody?.isDynamic = false
        
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
    }
    
    func initWalls(size: CGSize) {
        leftWall = SKSpriteNode()
        leftWall.position = CGPoint(x: 0 - 5, y: size.height / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: size.height))
        leftWall.physicsBody?.isDynamic = false

        rightWall = SKSpriteNode()
        rightWall.position = CGPoint(x: (size.width * 2) + 5, y: size.height / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: size.height))
        rightWall.physicsBody?.isDynamic = false
    }
    
    func initBackground(size: CGSize) {
        background = SKSpriteNode(imageNamed: "bg_night")
        background.size = size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        
        backgroundTwo = SKSpriteNode(imageNamed: "bg_night")
        backgroundTwo.size = size
        backgroundTwo.position = CGPoint(x: size.width * 1.5, y: size.height / 2)
        backgroundTwo.zPosition = -1
    }
    
    func initCrates(size: CGSize) {
        let crateSize : CGSize = CGSize(width: 50, height: 50)

        crateOne = SKSpriteNode(imageNamed: "crate")
        crateOne.size = crateSize
        crateOne.physicsBody = SKPhysicsBody(rectangleOf: crateSize)
        crateOne.position = CGPoint(x: size.width * (2/3), y: 105)
        crateOne.physicsBody?.isDynamic = false
        
        crateTwo = SKSpriteNode(imageNamed: "crate")
        crateTwo.size = crateSize
        crateTwo.physicsBody = SKPhysicsBody(rectangleOf: crateSize)
        crateTwo.position = CGPoint(x: size.width * (4/3), y: 105)
        crateTwo.physicsBody?.isDynamic = false
    }
}

