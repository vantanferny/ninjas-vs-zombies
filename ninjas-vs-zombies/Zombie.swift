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
    
    var walkAnimationRunning: Bool = false
    var runAnimationRunning: Bool = false
    var hurtAnimationRunning: Bool = false
    var attackAnimationRunning: Bool = false
    var dieAnimationRunning: Bool = false
    
    var attackMode: Bool = false
    var hands: SKNode!

    var leftEnd: CGFloat!
    var rightEnd: CGFloat!

    init(position : CGPoint, leftEnd : CGFloat, rightEnd : CGFloat) {
        super.init()

        loadAnimations()
        initProperties(position: position, leftEnd: leftEnd, rightEnd: rightEnd)
        initImage()
        initHands()

        self.addChild(image)
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
    
    func initiateAttackMode() {
        attackMode = true
        
        attack()
    }

    func attack() {
        walkAnimationRunning = false
        runAnimationRunning = false

        if attackAnimationRunning == true || hurtAnimationRunning == true {
            return
        }

        attackAnimationRunning = true

        // hands
        hands.position = CGPoint(x: image.position.x + ((image.size.width / 1.8) * image.xScale), y: image.position.y)
        self.addChild(hands)
        hands.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.removeFromParent()
        ]))

        // attack animaton
        let attackSequence = (SKAction.sequence([
            zombieAttackAnimation,
            SKAction.wait(forDuration: 0.5),
        ]))

        image.run(attackSequence, completion: {() -> Void in
            self.attackAnimationRunning = false
            if self.attackMode {
                self.attack()
            }
        })
    }

    func beHurt() {
        guard lives > 0 else {
            return
        }

        walkAnimationRunning = false
        runAnimationRunning = false

        lives = lives - 1

        if lives == 0 {
            image.run(SKAction.wait(forDuration: 0.3), completion: {() -> Void in
                self.die()
            })
        } else {
            image.run(SKAction.wait(forDuration: 0.3), completion: {() -> Void in
                guard !self.hurtAnimationRunning else {
                    return
                }
                
                self.hurtAnimationRunning = true

                self.image.size.width = 50
                self.image.run(self.zombieHurtAnimation, completion: {() -> Void in
                    self.beIdle()
                })
            })
        }
    }

    func die() {
        walkAnimationRunning = false
        runAnimationRunning = false

        guard !dieAnimationRunning else {
            return
        }
        dieAnimationRunning = true

        image.removeAllActions()
        image.size.width = 70

        image.run(zombieDieAnimation, completion: {() -> Void in
            self.image.run(SKAction.wait(forDuration: 1), completion: {() -> Void in
                self.removeFromParent()
            })
        })
    }

    func reset() {
        walkAnimationRunning = false
        runAnimationRunning = false
    }

    func beIdle() {
        walkAnimationRunning = false
        runAnimationRunning = false
        hurtAnimationRunning = false

        image.removeAllActions()
        image.size = CGSize(width: 40, height: 70)
        image.run(zombieIdleAnimation)
    }

    private func initProperties(position : CGPoint, leftEnd : CGFloat, rightEnd : CGFloat) {
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 70))
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = Physics.physicalBodies.zombie.rawValue
        self.physicsBody?.collisionBitMask = Physics.physicalBodies.floor.rawValue
        
        self.leftEnd = leftEnd
        self.rightEnd = rightEnd
    }

    private func animateWalking() {
        runAnimationRunning = false

        if !walkAnimationRunning {
            image.size.width = 40
            image.run(zombieWalkAnimation)

            walkAnimationRunning = true
        }
    }
    
    private func animateRunning() {
        walkAnimationRunning = false

        if !runAnimationRunning {
            image.size.width = 50
            
            image.run(zombieRunAnimation, completion: {() -> Void in
                self.image.run(self.zombieRunningAnimation)
            })

            runAnimationRunning = true
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
    }

    private func reverseHorizontalOrientation() {
        self.xScale = self.xScale * -1
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



