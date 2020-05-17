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

    var zombie1: Zombie!
    var zombie2: Zombie!
    var zombie3: Zombie!
    
    var cs: ControlSystem!

    var floor: SKSpriteNode!
    var upperGround: SKNode!
    var crateOne: SKSpriteNode!
    var crateTwo: SKSpriteNode!

    var leftButtonTouched: Bool = false
    var rightButtonTouched: Bool = false
    var leftButtonTwoTouched: Bool = false
    var rightButtonTwoTouched: Bool = false
    
    let cameraNode = SKCameraNode()
    var cameraPlayerLock = false

    enum physicalBodies : UInt32 {
        case floor = 1
        case player = 2
        case weapon = 3
        case zombie = 4
    }

    override func didMove(to view: SKView)  {
        initEnv()
        initPlayer()
        initZombies()
        initCamera()
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
            (contact.bodyA.categoryBitMask == physicalBodies.floor.rawValue) &&
            (contact.bodyB.categoryBitMask == physicalBodies.player.rawValue)
        ) || (
            (contact.bodyA.categoryBitMask == physicalBodies.player.rawValue) &&
            (contact.bodyB.categoryBitMask == physicalBodies.floor.rawValue)
        )

        if playerHitFloor && self.player.jumpAnimationRunning {
            self.player.beIdle()
        }
        
        // attack
    }

    func initEnv() {
        let env = Environment(size: self.frame.size)
        
        floor = env.floor
        crateOne = env.crateOne
        crateTwo = env.crateTwo
        upperGround = env.upperGround

        self.addChild(floor)
        self.addChild(crateOne)
        self.addChild(crateTwo)
        self.addChild(upperGround)

        self.addChild(env.leftWall)
        self.addChild(env.rightWall)
        self.addChild(env.background)
        self.addChild(env.backgroundTwo)
    }

    func initPlayer() {
        player = Ninja(size: self.frame.size)

        self.addChild(player)
    }
    
    func initZombies() {
        let position1 = CGPoint(x: self.frame.size.width * 0.8 , y: 200)
        let position2 = CGPoint(x: self.frame.size.width * 1.5 , y: 200)
        let position3 = CGPoint(x: self.frame.size.width * 1.7 , y: 500)

        zombie1 = Zombie(position: position1)
        zombie2 = Zombie(position: position2)
        zombie3 = Zombie(position: position3)

        self.addChild(zombie1)
        self.addChild(zombie2)
        self.addChild(zombie3)
    }

    func initControlSystem() {
        cs = ControlSystem(size: self.frame.size)

        for button in cs.buttons {
            cameraNode.addChild(button)
        }

        self.addChild(cameraNode)
    }
    
    func initPhysics() {
        // main floor
        floor.physicsBody?.categoryBitMask = physicalBodies.floor.rawValue
        floor.physicsBody?.contactTestBitMask = physicalBodies.player.rawValue
        
        // additional floor-like surfaces
        upperGround.physicsBody?.categoryBitMask = physicalBodies.floor.rawValue
        crateOne.physicsBody?.categoryBitMask = physicalBodies.floor.rawValue
        crateTwo.physicsBody?.categoryBitMask = physicalBodies.floor.rawValue
        
        // player
        player.physicsBody?.categoryBitMask = physicalBodies.player.rawValue
        player.physicsBody?.contactTestBitMask = physicalBodies.floor.rawValue
        
        // sword
        player.physicsBody?.categoryBitMask = physicalBodies.player.rawValue
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

        self.addChild(sword)
    }

    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
    }
}

