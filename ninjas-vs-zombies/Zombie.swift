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
    var image: SKSpriteNode!

    var zombieIdleAnimation: SKAction!
    var zombieWalkAnimation: SKAction!
    var zombieRunAnimation: SKAction!
    var zombieRunningAnimation: SKAction!
    var zombieAttackAnimation: SKAction!
    var zombieHurtAnimation: SKAction!
    var zombieDieAnimation: SKAction!
    
    let walkingSpeed: Int = 40
    let runningSpeed: Int = 70
    
    var lives: Int = 2

    var hands: SKNode!

    var leftEnd: CGFloat!
    var rightEnd: CGFloat!
    
    enum states {
        case idle
        case attacking
        case patroling
        case hunting
        case dying
    }
    
    enum animations {
        case idle
        case walking
        case running
        case hurting
        case attacking
        case dying
    }

    var state = states.idle
    var animation = animations.idle

    init(position : CGPoint, leftEnd : CGFloat, rightEnd : CGFloat, patrolMode: Bool) {
        super.init()

        loadAnimations()
        initProperties(position: position, leftEnd: leftEnd, rightEnd: rightEnd, patrolMode: patrolMode)
        initImage()
        initHands()

        self.addChild(image)
    }
    
    func switchState(newState: states) {
        switch newState {
        case states.idle:
            state = states.patroling
        case states.attacking:
            state = states.attacking
        case states.patroling:
            state = states.patroling
        case states.hunting:
            state = states.hunting
        case states.dying:
            state = states.dying
        }
    }
    
    func verifyState(inputState: states) -> Bool {
        return state == inputState
    }
    
    func switchAnimation(value: animations) {
        switch value {
        case animations.idle:
            animation = animations.idle
        case animations.walking:
            animation = animations.walking
        case animations.running:
            animation = animations.running
        case animations.hurting:
            animation = animations.hurting
        case animations.attacking:
            animation = animations.attacking
        case animations.dying:
            animation = animations.dying
        }
    }
    
    func verifyAnimation(value: animations) -> Bool {
        return animation == value
    }

    func patrol() {
        if self.xScale > 0{
            walkRight()
            
            if self.position.x >= rightEnd {
                walkLeft()
            }
        } else {
            walkLeft()

            if self.position.x <= leftEnd {
                walkRight()
            }
        }
    }

    func walkLeft() {
        animateWalking()

        if self.xScale > 0 {
            reverseHorizontalOrientation()
        }

        self.physicsBody?.applyForce(CGVector(dx:-walkingSpeed, dy: 0))
    }

    func walkRight() {
        animateWalking()

        if self.xScale < 0 {
            reverseHorizontalOrientation()
        }

        self.physicsBody?.applyForce(CGVector(dx:walkingSpeed, dy: 0))
    }

    func runLeft() {
        animateRunning()

        if self.xScale > 0 {
            reverseHorizontalOrientation()
        }

        self.physicsBody?.applyForce(CGVector(dx: -runningSpeed, dy: 0))
    }

    func runRight() {
        animateRunning()

        if self.xScale < 0 {
            reverseHorizontalOrientation()
        }

        self.physicsBody?.applyForce(CGVector(dx: runningSpeed, dy: 0))
    }
    
    func initiatePatrolMode() {
        switchState(newState: states.patroling)
    }

    func initiateAttackMode(facingRight: Bool) {

        switchState(newState: states.attacking)
        
        if ((facingRight && self.xScale < 0) || (!facingRight && self.xScale > 0)) {
            reverseHorizontalOrientation()
        }

        attack()
    }

    func attack() {
        if verifyAnimation(value: animations.attacking) || verifyAnimation(value: animations.hurting) {
            return
        }
        
        switchAnimation(value: animations.attacking)

        // hands
        hands.position = CGPoint(x: image.position.x + (image.size.width / 1.8), y: image.position.y)

        let handsAttackSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.removeFromParent()
        ])

        image.run(SKAction.wait(forDuration: 0.5), completion: {() -> Void in
            guard self.childNode(withName: "hands") == nil else {
                return
            }

            self.addChild(self.hands)
            self.hands.run(handsAttackSequence)
        })

        // attack animaton
        let attackSequence = (SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            zombieAttackAnimation,
        ]))

        image.run(attackSequence, completion: {() -> Void in
            self.beIdle()

            if self.verifyState(inputState: states.attacking) {
                self.attack()
            }
        })
    }
    
    func addHands() {
        self.addChild(hands)
    }

    func beHurt() {
        guard lives > 0 else {
            return
        }

        switchAnimation(value: animations.hurting)

        lives = lives - 1

        if lives == 0 {
            switchState(newState: states.dying)

            image.run(SKAction.wait(forDuration: 0.3), completion: {() -> Void in
                self.die()
            })
        } else {
            image.run(SKAction.wait(forDuration: 0.3), completion: {() -> Void in
                guard !self.verifyAnimation(value: animations.running) else {
                    return
                }
                
                self.switchAnimation(value: animations.running)

                self.image.size.width = 50
                self.image.run(self.zombieHurtAnimation, completion: {() -> Void in
                    self.beIdle()
                })
            })
        }
    }

    func die() {
        guard !verifyAnimation(value: animations.dying) else {
            return
        }
        
        switchAnimation(value: animations.dying)

        image.removeAllActions()
        image.size.width = 70

        image.run(zombieDieAnimation, completion: {() -> Void in
            self.image.run(SKAction.wait(forDuration: 1), completion: {() -> Void in
                self.removeFromParent()
            })
        })
    }

    func beIdle() {
        switchAnimation(value: animations.idle)

        image.removeAllActions()
        image.size = CGSize(width: 40, height: 70)
        image.run(zombieIdleAnimation)
    }

    private func initProperties(position : CGPoint, leftEnd : CGFloat, rightEnd : CGFloat, patrolMode: Bool) {
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 70))
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = Physics.physicalBodies.zombie.rawValue
        self.physicsBody?.collisionBitMask = Physics.physicalBodies.floor.rawValue

        if patrolMode {
            switchState(newState: states.patroling)
        }

        self.leftEnd = leftEnd
        self.rightEnd = rightEnd
    }

    private func animateWalking() {
        if !verifyAnimation(value: animations.walking) {
            image.size.width = 40
            image.run(zombieWalkAnimation)

            switchAnimation(value: animations.walking)
        }
    }
    
    private func animateRunning() {
        if !verifyAnimation(value: animations.running) {
            image.size.width = 50
            
            image.run(zombieRunAnimation, completion: {() -> Void in
                self.image.run(self.zombieRunningAnimation)
            })

            switchAnimation(value: animations.running)
        }
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
    
    private func initImage() {
        image = SKSpriteNode()
        beIdle()
    }
    
    private func initHands() {
        hands = SKNode()
        hands.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 1))
        hands.physicsBody?.isDynamic = false
        
        hands.physicsBody?.categoryBitMask = Physics.physicalBodies.hands.rawValue
        hands.physicsBody?.contactTestBitMask = Physics.physicalBodies.player.rawValue
        hands.physicsBody?.collisionBitMask = 0
        hands.name = "hands"
    }

    private func reverseHorizontalOrientation() {
        self.xScale = self.xScale * -1
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



