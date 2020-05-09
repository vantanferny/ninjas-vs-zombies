//
//  ControlSystem.swift
//  ninjas-vs-zombies
//
//  Created by Anferny Vanta on 5/4/20.
//  Copyright © 2020 Anferny Vanta. All rights reserved.
//

import SpriteKit

class ControlSystem {
    let buttons: [SKSpriteNode]

    var leftButton: SKSpriteNode
    var rightButton: SKSpriteNode
    var jumpButton: SKSpriteNode
    var attackButton: SKSpriteNode
    var resetButton: SKSpriteNode
    
    let btnSize = CGSize(width: 40, height: 40)
    let btnZPosition = 1 as CGFloat
    let btnPositionHeight = 50 as CGFloat

    init(size: CGSize) {
        let leftSide = size.width / 7
        let rightSide = (size.width / 7) * 4
        let btnMargin = 70 as CGFloat

        leftButton = SKSpriteNode(imageNamed: "btn-left")
        leftButton.name = "leftButton"
        leftButton.position = CGPoint(x: leftSide, y: btnPositionHeight)
        
        jumpButton = SKSpriteNode(imageNamed: "btn-jump")
        jumpButton.name = "jumpButton"
        jumpButton.position = CGPoint(x: leftSide + btnMargin, y: btnPositionHeight)
        
        rightButton = SKSpriteNode(imageNamed: "btn-right")
        rightButton.name = "rightButton"
        rightButton.position = CGPoint(x: leftSide + (btnMargin * 2), y: btnPositionHeight)
        
        attackButton = SKSpriteNode(imageNamed: "btn-attack")
        attackButton.name = "attackButton"
        attackButton.position = CGPoint(x: rightSide, y: btnPositionHeight)

        resetButton = SKSpriteNode(imageNamed: "btn-reset")
        resetButton.name = "resetButton"
        resetButton.position = CGPoint(x: rightSide + btnMargin, y: btnPositionHeight)

        buttons = [
            leftButton,
            rightButton,
            jumpButton,
            attackButton,
            resetButton,
        ]

        for button in self.buttons {
            button.size = btnSize
            button.zPosition = btnZPosition
        }
    }
}
