//
//  Hud.swift
//  ninjas-vs-zombies
//
//  Created by Anferny Vanta on 5/23/20.
//  Copyright © 2020 Anferny Vanta. All rights reserved.
//

import Foundation
import SpriteKit

class Hud {
    var hearts : SKNode!
    var xStartingPoint: CGFloat!
    var yScreenPosition : CGFloat!
    let xMargin : CGFloat = 40

    init(size: CGSize, lifeCount: Int) {
        initHearts(size: size, lifeCount: lifeCount)
    }

    func initHearts(size: CGSize, lifeCount: Int) {
        hearts = SKNode()
        hearts.name = "hearts"

        xStartingPoint = size.width - (size.width * 0.8)
        yScreenPosition = size.height * 0.4

        for count in 1...lifeCount {
            let heart: SKSpriteNode = produceHeart(id: count)

            hearts.addChild(heart)
        }
    }
    
    func produceHeart(id: Int) -> SKSpriteNode {
        let heart: SKSpriteNode = SKSpriteNode(imageNamed: "heart")
        heart.size = CGSize(width: 40, height: 40)
        heart.zPosition = 1
        heart.name = id.description

        let x : CGFloat = xStartingPoint + (xMargin * CGFloat(id))
        heart.position = CGPoint(x: x,y: yScreenPosition)

        return heart
    }

    func updateHeartCount(lifeCount: Int) {
        guard lifeCount != hearts.children.count else {
            return
        }

        let i : Int = abs(lifeCount - hearts.children.count)

        if lifeCount > hearts.children.count {
            for _ in 1...i {
                let heart: SKSpriteNode = produceHeart(id: hearts.children.count + 1)

                hearts.addChild(heart)
            }
        } else {
            for _ in 1...i {
                hearts.childNode(withName: String(hearts.children.count))?.removeFromParent()
            }
        }
    }
}
