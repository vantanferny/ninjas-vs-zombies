//
//  GameScene.swift
//  ninjas-vs-zombies
//
//  Created by Anferny Vanta on 5/4/20.
//  Copyright © 2020 Anferny Vanta. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: Ninja!
    var zombie: Zombie!
    var floor: SKSpriteNode!

    var leftButtonTouched: Bool = false
    var rightButtonTouched: Bool = false
    var leftButtonTwoTouched: Bool = false
    var rightButtonTwoTouched: Bool = false
    
    enum physicalBodies : UInt32 {
        case floor = 1
        case player = 2
    }

    override func didMove(to view: SKView)  {
        initFloor()
        initPlayer()
        initZombie()
        initControlSystem()
        initPhysics()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchedNode = atPoint(touch.location(in: self))

            if touchedNode.name == "leftButton" {
                leftButtonTouched = true
            } else if touchedNode.name == "rightButton" {
                rightButtonTouched = true
            }
            
            if touchedNode.name == "leftButtonTwo" {
                leftButtonTwoTouched = true
            } else if touchedNode.name == "rightButtonTwo" {
                rightButtonTwoTouched = true
            }

            if touchedNode.name == "jumpButton" {
//                self.player.jump()
            }

            if touchedNode.name == "attackButton" {
//                self.player.attack()
                self.zombie.attack()
            }

            if touchedNode.name == "resetButton" {
//                self.player.reset()
                self.zombie.reset()
            }

            if touchedNode.name == "hurtButton" {
//                self.player.die()
                self.zombie.beHurt()
            }

            if touchedNode.name == "dieButton" {
//                self.player.die()
                self.zombie.die()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let playerHitFloor: Bool = (
            (contact.bodyA.categoryBitMask == physicalBodies.floor.rawValue) &&
            (contact.bodyB.categoryBitMask == physicalBodies.player.rawValue)
        ) || (
            (contact.bodyA.categoryBitMask == physicalBodies.player.rawValue) &&
            (contact.bodyB.categoryBitMask == physicalBodies.floor.rawValue)
        )

        if playerHitFloor && self.player.jumpAnimationRunning {
            self.player.beIdle()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if leftButtonTouched || rightButtonTouched || leftButtonTwoTouched || rightButtonTwoTouched {
            self.player.beIdle()
        }
        
        leftButtonTouched = false
        rightButtonTouched = false
        leftButtonTwoTouched = false
        rightButtonTwoTouched = false

        self.player.physicsBody?.velocity.dx = 0
    }

    func initFloor() {
        floor = SKSpriteNode()
        floor.position = CGPoint(x: self.frame.size.width / 2, y: 0)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 160))

        // don't make it move
        floor.physicsBody?.isDynamic = false

        self.addChild(floor)
    }

    func initPlayer() {
        player = Ninja(size: self.frame.size)

        self.addChild(player)
    }
    
    func initZombie() {
        zombie = Zombie(size: self.frame.size)

        self.addChild(zombie)
    }

    func initControlSystem() {
        let cs = ControlSystem(size: self.frame.size)

        for button in cs.buttons {
            self.addChild(button)
        }
    }
    
    func initPhysics() {
        floor.physicsBody?.categoryBitMask = physicalBodies.floor.rawValue
        floor.physicsBody?.contactTestBitMask = physicalBodies.player.rawValue

        player.physicsBody?.categoryBitMask = physicalBodies.player.rawValue
        player.physicsBody?.contactTestBitMask = physicalBodies.floor.rawValue
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        if (leftButtonTouched == true) {
            self.zombie.walkLeft()
        } else if (rightButtonTouched == true) {
            self.zombie.walkRight()
        } else if (leftButtonTwoTouched == true) {
            self.zombie.runLeft()
        } else if (rightButtonTwoTouched == true) {
            self.zombie.runRight()
        }
    }

    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
    }
}

