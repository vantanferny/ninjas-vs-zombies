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
    var cs: ControlSystem!
    var hud: Hud!
    var cameraNode: SKCameraNode!

    override func didMove(to view: SKView)  {
        initEnv()
        initPlayer()
        initZombies()
        initCamera()
        initControlSystem()
        initHud()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchedNode = atPoint(touch.location(in: self))

            if touchedNode.name == "leftButton" {
                cs.leftButtonTouched = true
                
            } else if touchedNode.name == "rightButton" {
                cs.rightButtonTouched = true
            }

            if touchedNode.name == "jumpButton" {
                player.jump()
            }

            if touchedNode.name == "attackButton" {
                player.attack()
            }

            if touchedNode.name == "resetButton" {
                player.die()
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if cs.leftButtonTouched || cs.rightButtonTouched {
            self.player.beIdle()
        }

        cs.leftButtonTouched = false
        cs.rightButtonTouched = false

        self.player.physicsBody?.velocity.dx = 0
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // body assignments
        var bodyOne : SKPhysicsBody
        var bodyTwo : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyOne = contact.bodyA
            bodyTwo = contact.bodyB
        } else {
            bodyOne = contact.bodyB
            bodyTwo = contact.bodyA
        }

        // interactions
        // jump stabilization
        let playerHitFloor: Bool = (
            (bodyOne.categoryBitMask == Physics.physicalBodies.floor.rawValue) &&
            (bodyTwo.categoryBitMask == Physics.physicalBodies.player.rawValue)
        )

        if playerHitFloor {
            self.player.resetJumpCount()
            
            if self.player.jumpAnimationRunning {
                self.player.beIdle()
            }
        }

        // attack
        let swordHitZombie: Bool = (
            (bodyOne.categoryBitMask == Physics.physicalBodies.sword.rawValue) &&
            (bodyTwo.categoryBitMask == Physics.physicalBodies.zombie.rawValue)
        )

        if swordHitZombie {
            let zombie = bodyTwo.node as! Zombie

            zombie.beHurt()
        }
        
        // zombie attack mode
        let zombieHitPlayer: Bool = (
            (bodyOne.categoryBitMask == Physics.physicalBodies.player.rawValue) &&
            (bodyTwo.categoryBitMask == Physics.physicalBodies.zombie.rawValue)
        )

        if zombieHitPlayer {
            let zombie = bodyTwo.node as! Zombie

            zombie.initiateAttackMode()
        }
        
        // zombie attack
        let zombieAttackPlayer: Bool = (
            (bodyOne.categoryBitMask == Physics.physicalBodies.player.rawValue) &&
            (bodyTwo.categoryBitMask == Physics.physicalBodies.hands.rawValue)
        )

        if zombieAttackPlayer {
            let damage : Int = 1

            player.loseLife(damage: damage)
            hud.updateHeartCount(lifeCount: player.lives)

            refreshCameraHud()
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        // body assignment
        var bodyOne : SKPhysicsBody
        var bodyTwo : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyOne = contact.bodyA
            bodyTwo = contact.bodyB
        } else {
            bodyOne = contact.bodyB
            bodyTwo = contact.bodyA
        }

        // interactions
        let zombieStopHittingPlayer: Bool = (
            (bodyOne.categoryBitMask == Physics.physicalBodies.player.rawValue) &&
            (bodyTwo.categoryBitMask == Physics.physicalBodies.zombie.rawValue)
        )

        if zombieStopHittingPlayer {
            let zombie = bodyTwo.node as! Zombie

            zombie.attackMode = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        if (cs.leftButtonTouched == true) {
            self.player.moveLeft()
        } else if (cs.rightButtonTouched == true) {
            self.player.moveRight()
        }

        if (self.player.position.x >= self.frame.size.width / 2) && (self.player.position.x <= self.frame.size.width * 1.5) {
            self.cameraNode.position.x = self.player.position.x
        }
    }

    func initEnv() {
        let env = Environment(size: self.frame.size)

        for element in env.elements {
            self.addChild(element)
        }
    }

    func initPlayer() {
        player = Ninja(size: self.frame.size)

        self.addChild(player)
    }
    
    func initZombies() {
        // add zombies by adding their positions
        let positions : Array<CGPoint> = [
            CGPoint(x: self.frame.size.width * 0.4 , y: 200),
            CGPoint(x: self.frame.size.width * 1.5 , y: 200),
            CGPoint(x: self.frame.size.width * 1.7 , y: 500)
        ]

        var count = 0
        for position in positions {
            let zombie = Zombie(position: position, id: count)

            self.addChild(zombie)

            count = count + 1
        }
    }

    func initCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(cameraNode)

        self.camera = cameraNode
    }

    func initControlSystem() {
        cs = ControlSystem(size: self.frame.size)

        for button in cs.buttons {
            cameraNode.addChild(button)
        }
    }
    
    func initHud() {
        hud = Hud(size: self.size, lifeCount: player.lives)

        cameraNode.addChild(hud.hearts)
    }
    
    func refreshCameraHud() {
        cameraNode.childNode(withName: "hearts")?.removeFromParent()
        cameraNode.addChild(hud.hearts)
    }

    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
    }
}

