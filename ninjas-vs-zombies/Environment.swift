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

    init(size : CGSize) {
        initFloor(size: size)
    }
    
    func initFloor(size: CGSize) {
        floor = SKSpriteNode()
        floor.position = CGPoint(x: size.width / 2, y: 0)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 160))

        // don't make it move
        floor.physicsBody?.isDynamic = false
    }
}

