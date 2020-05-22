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
    var zombies: Array<Zombie>!
    var controlSystem: ControlSystem!
    var cameraNode: SKCameraNode!

    override func didMove(to view: SKView)  {
        initEnv()
        initPlayer()
        initZombies()
        initCamera()
        initControlSystem()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchedNode = atPoint(touch.location(in: self))

            if touchedNode.name == "leftButton" {
                controlSystem.leftButtonTouched = true
                
            } else if touchedNode.name == "rightButton" {
                controlSystem.rightButtonTouched = true
            }

            if touchedNode.name == "jumpButton" {
                self.player.jump()
            }

            if touchedNode.name == "attackButton" {
                self.player.attack()
            }

            if touchedNode.name == "resetButton" {
                self.player.reset()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        if (controlSystem.leftButtonTouched == true) {
            self.player.moveLeft()
        } else if (controlSystem.rightButtonTouched == true) {
            self.player.moveRight()
        }

        if (self.player.position.x >= self.frame.size.width / 2) && (self.player.position.x <= self.frame.size.width * 1.5) {
            self.cameraNode.position.x = self.player.position.x
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if controlSystem.leftButtonTouched || controlSystem.rightButtonTouched {
            self.player.beIdle()
        }

        controlSystem.leftButtonTouched = false
        controlSystem.rightButtonTouched = false

        self.player.physicsBody?.velocity.dx = 0
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // jump stabilization
        let playerHitFloor: Bool = (
            (contact.bodyA.categoryBitMask == Physics.physicalBodies.floor.rawValue) &&
            (contact.bodyB.categoryBitMask == Physics.physicalBodies.player.rawValue)
        ) || (
            (contact.bodyA.categoryBitMask == Physics.physicalBodies.player.rawValue) &&
            (contact.bodyB.categoryBitMask == Physics.physicalBodies.floor.rawValue)
        )

        if playerHitFloor && self.player.jumpAnimationRunning {
            self.player.beIdle()
        }
        
        // attack
        let swordHitZombie: Bool = (
            (contact.bodyA.categoryBitMask == Physics.physicalBodies.zombie.rawValue) &&
            (contact.bodyB.categoryBitMask == Physics.physicalBodies.sword.rawValue)
        ) ||
        (
            (contact.bodyA.categoryBitMask == Physics.physicalBodies.sword.rawValue) &&
            (contact.bodyB.categoryBitMask == Physics.physicalBodies.zombie.rawValue)
        )
        
        if swordHitZombie {
            var zombie : SKPhysicsBody

            if contact.bodyA.categoryBitMask == Physics.physicalBodies.zombie.rawValue {
                zombie = contact.bodyA
            } else {
                zombie = contact.bodyB
            }

            let zombieIdString : String! = zombie.node?.name?.replacingOccurrences(of: "zombie", with: "")
            let zombieId : Int = Int(zombieIdString)!
            
            zombies[zombieId].beHurt()
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
        zombies = []
        let position1 = CGPoint(x: self.frame.size.width * 0.5 , y: 200)
        let position2 = CGPoint(x: self.frame.size.width * 1.5 , y: 200)
        let position3 = CGPoint(x: self.frame.size.width * 1.7 , y: 500)

        let zombie1 = Zombie(position: position1, id: 0)
        let zombie2 = Zombie(position: position2, id: 1)
        let zombie3 = Zombie(position: position3, id: 2)

        zombies.append(zombie1)
        zombies.append(zombie2)
        zombies.append(zombie3)

        for zombie in zombies {
            self.addChild(zombie)
        }
    }
    
    func initCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

        self.camera = cameraNode
    }

    func initControlSystem() {
        controlSystem = ControlSystem(size: self.frame.size)

        for button in controlSystem.buttons {
            cameraNode.addChild(button)
        }

        self.addChild(cameraNode)
    }

    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
    }
}

