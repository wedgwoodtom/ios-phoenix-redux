//
//  GameScene.swift
//  PhoenixRedux
//
//  Created by Tom on 3/17/17.
//  Copyright © 2017 Tom Patterson. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation


enum Sound: String {
    case ShipShot = "shot1.wav"
    case BirdShot = "shot2.wav"
    case BirdExplosion = "explosion2.wav"
    case ShipExplosion = "ShipHit.wav"

    // TODO: Lame that I have to do this
    static func all() -> Array<Sound> {
        return [ShipShot, BirdShot, BirdExplosion, ShipExplosion]
    }
}

enum CollisionType : UInt32 {
    case Ship = 1
    case Bird = 2
    case Bullet = 4
}

enum GameState {
    case NotStarted
    case Running
    case ShipDestroyed
//    case Paused
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var titleLabel: SKLabelNode?
    private var titleBird: SKSpriteNode?
    private var titleStart: SKSpriteNode?

    private var ship : SKSpriteNode?
    
    private var contentCreated : Bool = false;

    private var gameState: GameState = GameState.NotStarted
    private var touchIsDown: Bool = false;
    private var shipsLeft: Int = 1;

    override func didMove(to view: SKView) {
        
        if (!contentCreated)
        {
            // Get label node from scene and store it for use later
            self.titleLabel = self.childNode(withName: "titleLabel") as? SKLabelNode
            self.titleBird = self.childNode(withName: "titleBird") as? SKSpriteNode
            self.titleStart = self.childNode(withName: "titleStart") as? SKSpriteNode

            self.physicsWorld.contactDelegate = self
            self.anchorPoint = CGPoint(x: 0, y: 0)

            preloadSounds()

            let bgImage = SKSpriteNode(imageNamed: "star_fields.png")
            bgImage.zPosition = -5
        
            bgImage.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
            bgImage.size = self.size
            addChild(bgImage)
            
            ship = SKSpriteNode(imageNamed: "Spaceship.png")
            if let ship = self.ship {
                ship.xScale = 0.25
                ship.yScale = 0.25
                ship.position = CGPoint(x: self.size.width/2, y: ship.size.height+90)
                
                // hack for iPad - how to fix this?
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    ship.position.y += 100
                }
                
                addChild(ship)

                // add ship physics
                ship.physicsBody = SKPhysicsBody(texture: (ship.texture)!, size: ship.size)
                ship.physicsBody?.isDynamic = false
                ship.physicsBody?.affectedByGravity = false
                ship.physicsBody?.categoryBitMask = CollisionType.Ship.rawValue
                ship.physicsBody?.contactTestBitMask = CollisionType.Bird.rawValue
                ship.physicsBody?.collisionBitMask = CollisionType.Bird.rawValue
            }

            gameState = GameState.NotStarted
            toggleGameControls(on: true)

            let firingTimer = Timer.scheduledTimer(
                    timeInterval: 0.4,
                    target: self,
                    selector: #selector(self.fireBullet),
                    userInfo: nil,
                    repeats: true)

            let birdTimer = Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(self.spawnPhoenix),
                    userInfo: nil,
                    repeats: true)

            contentCreated = true
        }

    }

    func toggleGameControls(on: Bool = true) {
        var action = on ? SKAction.fadeIn(withDuration: 2.0) : SKAction.fadeOut(withDuration: 2.0)

        if let label = self.titleLabel {
            label.position = CGPoint(x: self.size.width/2, y: self.size.height/1.5)
            label.alpha = 0.0
            label.run(action)

            if let titleBird = self.titleBird {
                titleBird.position = CGPoint(x: self.size.width/2, y: label.position.y + titleBird.size.height)
                titleBird.alpha = 0.0
                // hack for iPad
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    titleBird.position.y -= 100
                }
                titleBird.run(action)
            }

            if let titleStart = self.titleStart {
                titleStart.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
                titleStart.alpha = 0.0
                titleStart.run(action)
                titleStart.name = "startButton"
            }
        }
    }

    func endGame() {
        toggleGameControls(on: true)
        gameState = GameState.NotStarted
        shipsLeft = 0;
    }

    func startGame() {
        toggleGameControls(on: false)
        gameState = GameState.Running
        shipsLeft = 1;
    }

    func preloadSounds() {
        // They are cached once loaded (or seem to be).  Think about wrapping all this sound fctn into a class
        for sound in Sound.all() {
            playSound(sound: sound, now: false)
        }
    }

    func explosion(pos: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: "ExplosionParticle.sks")
        emitterNode!.particlePosition = pos
        self.addChild(emitterNode!)
//        emitterNode!.removeFromParent()

        playSound(sound: Sound.BirdExplosion)
        self.run(SKAction.wait(forDuration: 2.0), completion: { emitterNode!.removeFromParent() })
    }

    // TODO: Look at cleaning this up - make it a soundPLayer/Manager or something?
    func playSound(sound: Sound, now: Bool = true) {
        let sound = SKAction.playSoundFileNamed(sound.rawValue, waitForCompletion: false)
        if (now) {
            self.run(sound)
        }
    }

    func handleTouch(toPoint pos : CGPoint) {

        if (gameState == GameState.NotStarted) {
            let sprites: [SKNode] = self.nodes(at: pos)
            for sprite in sprites {
                if (sprite.name == "startButton") {
                    startGame()
                    return
                }
            }
        }

        if (gameState == GameState.Running) {
            ship?.position.x = pos.x
        }
    }
    
    func setupShip() {
    }

    func fireBullet() {

        if (touchIsDown == false || gameState != GameState.Running) {
           return
        }

        let bullet = SKSpriteNode(imageNamed: "bullet.png")
        bullet.zPosition = -1
        bullet.position = CGPoint(x: (ship?.position.x)!, y: (ship?.position.y)!)

        let move = SKAction.moveTo(y: self.size.height+50, duration: 1)
        let delete = SKAction.removeFromParent()
        playSound(sound: Sound.ShipShot)
        bullet.run(SKAction.sequence([move, delete]))
        self.addChild(bullet)


        // physics
        bullet.physicsBody = SKPhysicsBody(texture: (bullet.texture)!, size: (bullet.size))
        bullet.physicsBody?.isDynamic = false
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = CollisionType.Bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionType.Bird.rawValue
        bullet.physicsBody?.collisionBitMask = CollisionType.Bird.rawValue

    }

    func spawnPhoenix() {

        if (gameState != GameState.Running) {
            return
        }

        let bird = SKSpriteNode(imageNamed: "bird.png")
        bird.name = "bird"
        bird.xScale = 0.75
        bird.yScale = 0.75
//        let randomX = Int(arc4random_uniform(UInt32(Int(self.size.width))) + 1)

        let randomX = GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.size.width))
        
        bird.position = CGPoint(x: randomX, y: Int(self.size.height - bird.size.height / 2))

        let spin = SKAction.rotate(byAngle: CGFloat(3*M_PI), duration: 0.5)
        let fly = SKAction.moveTo(y: 0, duration: 3)
        let delete = SKAction.removeFromParent()
//        bird.run(SKAction.sequence([spin, fly, delete]))
        bird.run(SKAction.sequence([fly, delete]))

        self.addChild(bird)

        // physics
        bird.physicsBody = SKPhysicsBody(texture: (bird.texture)!, size: (bird.size))
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.categoryBitMask = CollisionType.Bird.rawValue
        bird.physicsBody?.contactTestBitMask = CollisionType.Bullet.rawValue
        bird.physicsBody?.collisionBitMask = CollisionType.Bullet.rawValue
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchIsDown = true
        for touch in touches {
            let pos = touch.location(in: self)
            self.handleTouch(toPoint: pos)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.handleTouch(toPoint: touch.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchIsDown = false
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchIsDown = false
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

    // Collision detection
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == CollisionType.Ship.rawValue && contact.bodyB.categoryBitMask == CollisionType.Bird.rawValue) {
            let bird = contact.bodyB.node
            handleCollision(bird: bird, ship: ship)
        }
        else if ((contact.bodyA.categoryBitMask == CollisionType.Bird.rawValue && contact.bodyB.categoryBitMask == CollisionType.Bullet.rawValue)
                || (contact.bodyA.categoryBitMask == CollisionType.Bullet.rawValue && contact.bodyB.categoryBitMask == CollisionType.Bird.rawValue)) {
            let bird = contact.bodyA.node
            let bullet = contact.bodyB.node
            handleCollision(bird: bird, bullet: bullet)
        }
    }

    func handleCollision(bird: SKNode?, ship: SKNode?) {
        if (bird?.parent == nil)
        {
            return
        }
        bird?.removeAllActions()
        bird?.removeFromParent()

        gameState = GameState.ShipDestroyed
        self.enumerateChildNodes(withName: "bird", using: {
            (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            node.removeFromParent()
        })

        self.explosion(pos: (ship?.position)!)

        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let move = SKAction.move(to: CGPoint(x: self.size.width/2, y: self.size.height/8), duration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 1.5)
//            let spin = SKAction.rotate(byAngle: CGFloat(2*M_PI), duration: 0.5)
        let firing = SKAction.run({
            self.gameState = GameState.Running
        })

        playSound(sound: Sound.ShipExplosion)
        ship?.run(SKAction.sequence([fadeOut, fadeIn, move, firing]))
    }

    func handleCollision(bird: SKNode?, bullet: SKNode?) {
        // blow up the bird
        // already removed, skip it
        if (bird?.parent == nil)
        {
            return
        }

        // playSound(sound: Sound.BirdShot)

        bird?.removeAllActions()
        bird?.removeFromParent()
        bullet?.removeAllActions()
        bullet?.removeFromParent()

        let explosionPosition = bird?.position
        explosion(pos: explosionPosition!)
    }


}


/**
// This method will get invoked by update:
-(void)moveInvadersForUpdate:(NSTimeInterval)currentTime {
    //1
    if (currentTime - self.timeOfLastMove < self.timePerMove) return;

    //2
    [self enumerateChildNodesWithName:kInvaderName usingBlock:^(SKNode *node, BOOL *stop) {
        switch (self.invaderMovementDirection) {
            case InvaderMovementDirectionRight:
                node.position = CGPointMake(node.position.x + 10, node.position.y);
                break;
            case InvaderMovementDirectionLeft:
                node.position = CGPointMake(node.position.x - 10, node.position.y);
                break;
            case InvaderMovementDirectionDownThenLeft:
            case InvaderMovementDirectionDownThenRight:
                node.position = CGPointMake(node.position.x, node.position.y - 10);
                break;
            InvaderMovementDirectionNone:
            default:
                break;
        }
    }];

    //3
    self.timeOfLastMove = currentTime;
}
**/



/*
 func lifeLost() {
 explosion(self.heroSprite.position)

 self.gamePaused = true


 // Play sound:
 runAction(soundAction)

 // remove one life from hud
 if self.remainingLifes>0 {
 self.lifeNodes[remainingLifes-1].alpha=0.0
 self.remainingLifes--;
 }

 // check if remaining lifes exists
 if (self.remainingLifes==0) {
 showGameOverAlert()
 }

 // Stop movement, fade out, move to center, fade in
 heroSprite.removeAllActions()
 self.heroSprite.runAction(SKAction.fadeOutWithDuration(1) , completion: {
 self.heroSprite.position = CGPointMake(self.size.width/2, self.size.height/2)
 self.heroSprite.runAction(SKAction.fadeInWithDuration(1), completion: {
 self.gamePaused = false
 })
 })
 }
*/



// TODO: Use this technique to speed thangs up - copy
//    func addEmitter(position:CGPoint){
//
//        var emitterToAdd   = emitter.copy() as SKEmitterNode
//
//        emitterToAdd.position = position
//
//        let addEmitterAction = SKAction.runBlock({self.addChild(emitterToAdd)})
//
//        var emitterDuration = CGFloat(emitter.numParticlesToEmit) * emitter.particleLifetime
//
//        let wait = SKAction.waitForDuration(NSTimeInterval(emitterDuration))
//
//        let remove = SKAction.runBlock({emitterToAdd.removeFromParent(); println("Emitter removed")})
//
//        let sequence = SKAction.sequence([addEmitterAction, wait, remove])
//
//        self.runAction(sequence)
//
//
//    }
