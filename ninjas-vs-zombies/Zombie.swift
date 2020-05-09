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
    
    var walkAnimationRunning: Bool = false
    var runAnimationRunning: Bool = false

    var defaultPosition: CGPoint!

    init(size : CGSize) {
        super.init()

        loadAnimations()
        initProperties(size: size)
        initImage()

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

    func attack() {
        walkAnimationRunning = false
        runAnimationRunning = false

        image.run(zombieAttackAnimation, completion: {() -> Void in
            self.beIdle()
        })
    }
    
    func beHurt() {
        walkAnimationRunning = false
        runAnimationRunning = false

        image.size.width = 50
        image.run(zombieHurtAnimation, completion: {() -> Void in
            self.beIdle()
        })
    }

    func die() {
        walkAnimationRunning = false
        runAnimationRunning = false

        image.size.width = 70
        image.run(zombieDieAnimation, completion: {() -> Void in
            self.image.removeAllActions()
        })
    }

    func reset() {
        walkAnimationRunning = false
        runAnimationRunning = false
        self.position = defaultPosition
    }

    func beIdle() {
        walkAnimationRunning = false
        runAnimationRunning = false

        image.removeAllActions()
        image.size = CGSize(width: 40, height: 70)
        image.run(zombieIdleAnimation)
    }
    
    private func initProperties(size: CGSize) {
        defaultPosition = CGPoint(x: (size.width / 4)*3, y: size.height)

        self.position = defaultPosition
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 70))
        self.physicsBody?.allowsRotation = false
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

    private func reverseHorizontalOrientation() {
        self.xScale = self.xScale * -1
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



