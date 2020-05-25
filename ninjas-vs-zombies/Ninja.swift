//
//  Ninja.swift
//  ninjas-vs-zombies
//
//  Created by Anferny Vanta on 5/4/20.
//  Copyright © 2020 Anferny Vanta. All rights reserved.
//

import Foundation
import SpriteKit

class Ninja : SKNode {
    var image: SKSpriteNode!

    var ninjaIdleAnimation: SKAction!
    var ninjaRunAnimation: SKAction!
    var ninjaJumpAnimation: SKAction!
    var ninjaAttackAnimation: SKAction!
    var ninjaDieAnimation: SKAction!

    var runAnimationRunning: Bool = false
    var jumpAnimationRunning: Bool = false
    
    enum states {
        case idle
        case running
        case jumping
        case dying
    }

    var state = states.idle
    
    func switchState(newState: states) {
        switch newState {
        case states.idle:
            state = states.idle
        case states.running:
            state = states.running
        case states.jumping:
            state = states.jumping
        case states.dying:
            state = states.dying
        }
    }

    func verifyState(inputState: states) -> Bool {
        return state == inputState
    }
    
    var jumpCount: Int = 2

    var defaultPosition: CGPoint!
    
    var lives = 3

    var sword: SKNode!

    init(size : CGSize) {
        super.init()

        loadAnimations()
        initProperties(size: size)
        initImage()
        initSword()

        self.addChild(image)
    }

    func moveLeft() {
        animateRunning()

        if self.xScale > 0 {
            reverseHorizontalOrientation()
        }

        self.physicsBody?.applyForce(CGVector(dx:-100, dy: 0))
    }

    func moveRight() {
        animateRunning()

        if self.xScale < 0 {
            reverseHorizontalOrientation()
        }

        self.physicsBody?.applyForce(CGVector(dx:100, dy: 0))
    }

    func jump() {
        guard jumpCount > 0 else {
            return
        }

        switchState(newState: states.jumping)

        image.size = CGSize(width: 60, height: 80)
        image.run(ninjaJumpAnimation, completion: {() -> Void in
            self.beIdle()
        })
        
        self.physicsBody?.applyImpulse(CGVector(dx:0, dy: 70))
        
        jumpCount = jumpCount - 1
    }
    
    func resetJumpCount() {
        jumpCount = 2
    }

    func attack() {
        runAnimationRunning = false
        image.size = CGSize(width: 90, height: 80)
        image.run(ninjaAttackAnimation, completion: {() -> Void in
            self.beIdle()
        })

        sword.position = CGPoint(x: image.position.x + ((image.size.width / 2.6) * image.xScale), y: image.position.y)
        self.addChild(sword)
        sword.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }
    
    func initSword() {
        sword = SKNode()
        sword.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 1))
        sword.physicsBody?.isDynamic = false
        
        sword.physicsBody?.categoryBitMask = Physics.physicalBodies.sword.rawValue
        sword.physicsBody?.contactTestBitMask = Physics.physicalBodies.zombie.rawValue
        sword.physicsBody?.collisionBitMask = 0
    }
    
    func loseLife(damage: Int) {
        guard lives > 0 else {
            return
        }

        lives = lives - damage

        if lives < 1 {
            die()
        }
    }

    func die() {
        switchState(newState: states.dying)

        image.size = CGSize(width: 80, height: 80)
        image.run(ninjaDieAnimation, completion: {() -> Void in
            self.image.removeAllActions()
            self.image.run(SKAction.wait(forDuration: 1), completion: {() -> Void in
                self.removeFromParent()
            })
        })
    }

    func reset() {
        switchState(newState: states.idle)
        self.position = defaultPosition
    }

    func beIdle() {
        switchState(newState: states.idle)

        image.size = CGSize(width: 40, height: 70)
        image.run(ninjaIdleAnimation)
    }
    
    private func initProperties(size: CGSize) {
        defaultPosition = CGPoint(x: size.width / 4, y: size.height)

        self.position = defaultPosition
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 70))
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = Physics.physicalBodies.player.rawValue
        self.physicsBody?.contactTestBitMask = Physics.physicalBodies.floor.rawValue + Physics.physicalBodies.zombie.rawValue + Physics.physicalBodies.heart.rawValue
        self.physicsBody?.collisionBitMask = Physics.physicalBodies.floor.rawValue + Physics.physicalBodies.zombie.rawValue
    }
    
    private func animateRunning() {
        guard !verifyState(inputState: states.running) && !verifyState(inputState: states.jumping) else {
            return
        }

        switchState(newState: states.running)

        image.size.width = 60
        image.run(ninjaRunAnimation)
    }
    
    private func loadAnimations() {
        // Idle
        var ninjaIdleTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "ninja_idle").textureNames.count{
            ninjaIdleTextures.append(SKTexture(imageNamed: "ninja_idle_\(i).png"))
        }

        ninjaIdleAnimation = SKAction.repeatForever(
            SKAction.animate(with: ninjaIdleTextures, timePerFrame: 0.1)
        )
        
        // Run
        var ninjaRunTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "ninja_run").textureNames.count{
            ninjaRunTextures.append(SKTexture(imageNamed: "ninja_run_\(i).png"))
        }

        ninjaRunAnimation = SKAction.repeatForever(
            SKAction.animate(with: ninjaRunTextures, timePerFrame: 0.1)
        )

        // Jump
        var ninjaJumpTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "ninja_jump").textureNames.count{
            ninjaJumpTextures.append(SKTexture(imageNamed: "ninja_jump_\(i).png"))
        }

        ninjaJumpAnimation = SKAction.animate(with: ninjaJumpTextures, timePerFrame: 0.1)

        // Attack
        var ninjaAttackTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "ninja_attack").textureNames.count{
            ninjaAttackTextures.append(SKTexture(imageNamed: "ninja_attack_\(i).png"))
        }
        
        ninjaAttackAnimation = SKAction.animate(with: ninjaAttackTextures, timePerFrame: 0.05)

        // Die
        var ninjaDieTextures = [SKTexture]()

        for i in 1...SKTextureAtlas(named: "ninja_dead").textureNames.count{
            ninjaDieTextures.append(SKTexture(imageNamed: "ninja_dead_\(i).png"))
        }

        ninjaDieAnimation = SKAction.repeat(
            SKAction.animate(with: ninjaDieTextures, timePerFrame: 0.1),
            count: 1
        )
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


