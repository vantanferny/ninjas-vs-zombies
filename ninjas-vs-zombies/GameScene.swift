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
    var cs: ControlSystem!

    var floor: SKSpriteNode!
    var leftWall: SKSpriteNode!
    var rightWall: SKSpriteNode!
    var background: SKSpriteNode!
    var backgroundTwo: SKSpriteNode!
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
    }

    override func didMove(to view: SKView)  {
        initEnv()
        initPlayer()
//        initZombie()
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

    func initEnv() {
        let env = Environment(size: self.frame.size)
        
        floor = env.floor
        leftWall = env.leftWall
        rightWall = env.rightWall
        background = env.background
        backgroundTwo = env.backgroundTwo
        crateOne = env.crateOne
        crateTwo = env.crateTwo

        self.addChild(floor)
        self.addChild(leftWall)
        self.addChild(rightWall)
        self.addChild(background)
        self.addChild(backgroundTwo)
        self.addChild(crateOne)
        self.addChild(crateTwo)
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
        cs = ControlSystem(size: self.frame.size)

        for button in cs.buttons {
            cameraNode.addChild(button)
        }

        self.addChild(cameraNode)
    }
    
    func initPhysics() {
        floor.physicsBody?.categoryBitMask = physicalBodies.floor.rawValue
        floor.physicsBody?.contactTestBitMask = physicalBodies.player.rawValue

        player.physicsBody?.categoryBitMask = physicalBodies.player.rawValue
        player.physicsBody?.contactTestBitMask = physicalBodies.floor.rawValue
    }
    
    func initCamera() {
        cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        self.camera = cameraNode
    }

    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
    }
}

