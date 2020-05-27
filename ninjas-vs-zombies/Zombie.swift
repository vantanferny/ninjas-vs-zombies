//
//  Zombie.swift
//  zombies-vs-zombies
//
//  Created by Anferny Vanta on 5/4/20.
//  Copyright © 2020 Anferny Vanta. All rights reserved.
//

import Foundation
import SpriteKit

class Zombie : SKNode {
    private var image: SKSpriteNode!

    private var zombieIdleAnimation: SKAction!
    private var zombieWalkAnimation: SKAction!
    private var zombieRunAnimation: SKAction!
    private var zombieRunningAnimation: SKAction!
    private var zombieAttackAnimation: SKAction!
    private var zombieHurtAnimation: SKAction!
    private var zombieDieAnimation: SKAction!
    
    private let walkingSpeed: CGFloat = 2
    private let runningSpeed: CGFloat = 3

    private var lives: Int = 50

    private var hands: SKNode!
    private let attackDelay : Double = 0.5

    private var leftEnd: CGFloat!
    private var rightEnd: CGFloat!

    private enum states {
        case idle
        case attacking
        case patroling
        case hunting
        case hurting
        case dying
    }

    private var state = states.idle // animation running
    private var mode = states.idle // main behaviour

    init(position : CGPoint, leftEnd : CGFloat, rightEnd : CGFloat, patrolMode: Bool) {
        super.init()

        loadAnimations()
        initProperties(position: position, leftEnd: leftEnd, rightEnd: rightEnd)
        
        initMode(patrolMode: patrolMode)

        self.addChild(image)
    }

    func initiatePatrolMode() {
        switchMode(value: states.patroling)
    }

    func initiateAttackMode(facingRight: Bool) {
        if ((facingRight && self.xScale < 0) || (!facingRight && self.xScale > 0)) {
            reverseHorizontalOrientation()
        }

        switchMode(value: states.attacking)
    }
    
    private func initProperties(position : CGPoint, leftEnd : CGFloat, rightEnd : CGFloat) {
        // zombie
        self.image = SKSpriteNode()
        self.image.size = CGSize(width: 0, height: 70)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 70))
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = Physics.physicalBodies.zombie.rawValue
        self.physicsBody?.collisionBitMask = Physics.physicalBodies.floor.rawValue

        self.leftEnd = leftEnd
        self.rightEnd = rightEnd
        
        // hands
        self.hands = SKNode()
        self.hands.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 1))
        self.hands.physicsBody?.isDynamic = false
        
        self.hands.physicsBody?.categoryBitMask = Physics.physicalBodies.hands.rawValue
        self.hands.physicsBody?.contactTestBitMask = Physics.physicalBodies.player.rawValue
        self.hands.physicsBody?.collisionBitMask = 0
        self.hands.name = "hands"
    }
    
    private func initMode(patrolMode: Bool) {
        if patrolMode {
            switchMode(value: states.patroling)
        } else {
            beIdle()
        }
    }

    private func switchState(value: states) {
        switch value {
        case states.idle:
            state = states.idle
        case states.patroling:
            state = states.patroling
        case states.hunting:
            state = states.hunting
        case states.attacking:
            state = states.attacking
        case states.hurting:
            state = states.hurting
        case states.dying:
            state = states.dying
        }
    }

    private func switchMode(value: states) {
        switch value {
        case states.patroling:
            mode = states.patroling

            patrol()
        case states.hunting:
            mode = states.hunting

            // hunt()
        case states.attacking:
            mode = states.attacking
            
            attack()
        default:
            mode = states.idle
        }
    }

    private func beIdle() {
        switchState(value: states.idle)
    
        image.size = CGSize(width: 40, height: 70)
        image.run(zombieIdleAnimation)
    }

    private func patrol() {
        walk()

        if patrolBorderReached() {
            reverseHorizontalOrientation()
        }
        
        image.run(SKAction.wait(forDuration: 0.05), completion: {() -> Void in
            if self.mode == states.patroling {
                self.patrol()
            }
        })
    }
    
    private func walk() {
        animateWalking()

        self.position.x = self.position.x + (self.xScale * walkingSpeed)
    }

    private func animateWalking() {
        if state != states.patroling {
            image.size.width = 40
            image.run(zombieWalkAnimation)

            switchState(value: states.patroling)
        }
    }

    private func run() {
        animateRunning()

        self.position.x = self.position.x + (self.xScale * runningSpeed)
    }
    
    private func animateRunning() {
        if state != states.hunting {
            image.size.width = 50
            
            image.run(zombieRunAnimation, completion: {() -> Void in
                self.image.run(self.zombieRunningAnimation)
            })

            switchState(value: states.hunting)
        }
    }

    private func attack() {
        if [states.attacking, states.hurting].contains(state) {
            return
        }

        switchState(value: states.attacking)

        // hands
        hands.position = CGPoint(x: image.position.x + (image.size.width / 1.8), y: image.position.y)
        image.run(SKAction.wait(forDuration: attackDelay), completion: {() -> Void in
            guard self.childNode(withName: "hands") == nil else {
                return
            }

            self.addChild(self.hands)
            self.hands.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.removeFromParent()
            ]))
        })

        // attack animation
        let attackWithDelay = SKAction.sequence([
            SKAction.wait(forDuration: attackDelay),
            zombieAttackAnimation,
        ])

        image.run(attackWithDelay, completion: {() -> Void in
            self.beIdle()

            if self.mode == states.attacking {
                self.attack()
            }
        })
    }

    func beHurt() {
        guard lives > 0 else {
            return
        }

        switchState(value: states.hurting)

        lives = lives - 1

        if lives == 0 {
            switchState(value: states.dying)

            image.run(SKAction.wait(forDuration: 0.3), completion: {() -> Void in
                self.die()
            })
        } else {
            image.run(SKAction.wait(forDuration: 0.3), completion: {() -> Void in
                self.image.size.width = 50
                self.image.run(self.zombieHurtAnimation, completion: {() -> Void in
                    self.switchState(value: self.mode)
                })
            })
        }
    }

    private func die() {
        if state == states.dying {
            return
        }
        
        switchState(value: states.dying)

        image.removeAllActions()
        image.size.width = 70
        image.run(zombieDieAnimation, completion: {() -> Void in
            self.image.run(SKAction.wait(forDuration: 1), completion: {() -> Void in
                self.removeFromParent()
            })
        })
    }
    
    private func patrolBorderReached() -> Bool {
        return self.position.x <= leftEnd || self.position.x >= rightEnd
    }

    private func reverseHorizontalOrientation() {
        self.xScale = self.xScale * -1
    }

    private func loadAnimations() {
        // Idle
        var zombieIdleTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "zombie_1_idle").textureNames.count{
            zombieIdleTextures.append(SKTexture(imageNamed: "zombie_1_idle_\(i).png"))
        }

        zombieIdleAnimation = SKAction.repeatForever(
            SKAction.animate(with: zombieIdleTextures, timePerFrame: 0.2)
        )
        
        // Walk
        var zombieWalkTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "zombie_1_walk").textureNames.count{
            zombieWalkTextures.append(SKTexture(imageNamed: "zombie_1_walk_\(i).png"))
        }
        
        zombieWalkAnimation = SKAction.repeatForever(
            SKAction.animate(with: zombieWalkTextures, timePerFrame: 0.1)
        )

        // Run
        var zombieRunTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "zombie_1_run").textureNames.count{
            zombieRunTextures.append(SKTexture(imageNamed: "zombie_1_run_\(i).png"))
        }

        zombieRunAnimation = SKAction.animate(with: zombieRunTextures, timePerFrame: 0.1)
        
        // Running
        
        var zombieRunningTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "zombie_1_run").textureNames.count{
            if i > 5 {
                    zombieRunningTextures.append(SKTexture(imageNamed: "zombie_1_run_\(i).png"))
            }
        }

        zombieRunningAnimation = SKAction.repeatForever(
            SKAction.animate(with: zombieRunningTextures, timePerFrame: 0.1)
        )

        // Attack
        var zombieAttackTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "zombie_1_attack").textureNames.count{
            zombieAttackTextures.append(SKTexture(imageNamed: "zombie_1_attack_\(i).png"))
        }
        
        zombieAttackAnimation = SKAction.animate(with: zombieAttackTextures, timePerFrame: 0.1)
        
        // Hurt
        var zombieHurtTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "zombie_1_hurt").textureNames.count{
            zombieHurtTextures.append(SKTexture(imageNamed: "zombie_1_hurt_\(i).png"))
        }

        zombieHurtAnimation = SKAction.animate(with: zombieHurtTextures, timePerFrame: 0.1)
        
        // Die
        var zombieDieTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "zombie_1_dead").textureNames.count{
            zombieDieTextures.append(SKTexture(imageNamed: "zombie_1_dead_\(i).png"))
        }

        zombieDieAnimation = SKAction.animate(with: zombieDieTextures, timePerFrame: 0.1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



