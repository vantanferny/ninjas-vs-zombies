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

    init(size : CGSize) {
        initFloor(size: size)
        initWalls(size: size)
    }
    
    func initFloor(size: CGSize) {
        floor = SKSpriteNode()
        floor.position = CGPoint(x: size.width / 2, y: 0)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 160))

        // don't make it move
        floor.physicsBody?.isDynamic = false
    }
    
    func initWalls(size: CGSize) {
        leftWall = SKSpriteNode()
        leftWall.position = CGPoint(x: 0, y: 300)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: size.height))
        leftWall.physicsBody?.isDynamic = false

        rightWall = SKSpriteNode()
        rightWall.position = CGPoint(x: size.width * 2 + 20, y: 0)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: size.height * 2))
        rightWall.physicsBody?.isDynamic = false
        
    }
}

