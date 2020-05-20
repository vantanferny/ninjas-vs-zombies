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
    var sword: SKNode!

    var zombies: Array<Zombie>!
    
    var cs: ControlSystem!

    var leftButtonTouched: Bool = false
    var rightButtonTouched: Bool = false
    
    let cameraNode = SKCameraNode()

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
                leftButtonTouched = true
                
            } else if touchedNode.name == "rightButton" {
                rightButtonTouched = true
            }

            if touchedNode.name == "jumpButton" {
                self.player.jump()
            }

            if touchedNode.name == "attackButton" {
                self.player.attack()

                slash()
            }

            if touchedNode.name == "resetButton" {
                self.player.reset()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        if (leftButtonTouched == true) {
            self.player.moveLeft()
        } else if (rightButtonTouched == true) {
            self.player.moveRight()
        }

        if (self.player.position.x >= self.frame.size.width / 2) && (self.player.position.x <= self.frame.size.width * 1.5) {
            self.cameraNode.position.x = self.player.position.x
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if leftButtonTouched || rightButtonTouched {
            self.player.beIdle()
        }
        
        leftButtonTouched = false
        rightButtonTouched = false

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
        
        // init zombie physical properties
        for zombie in zombies {
            self.addChild(zombie)
        }
    }

    func initControlSystem() {
        cs = ControlSystem(size: self.frame.size)

        for button in cs.buttons {
            cameraNode.addChild(button)
        }

        self.addChild(cameraNode)
    }

    func initCamera() {
        cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        self.camera = cameraNode
    }
    
    func slash() {
        sword = SKNode()
        sword.position = CGPoint(x: player.position.x + (player.image.size.width / 2.6), y: self.player.position.y)
        sword.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 1))
        sword.physicsBody?.isDynamic = false

        sword.physicsBody?.categoryBitMask = Physics.physicalBodies.sword.rawValue
        sword.physicsBody?.contactTestBitMask = Physics.physicalBodies.zombie.rawValue
        sword.physicsBody?.collisionBitMask = 0

        self.addChild(sword)
        
        sword.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }

    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
    }
}

