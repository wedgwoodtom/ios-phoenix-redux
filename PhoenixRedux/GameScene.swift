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



enum CollisionType : UInt32 {
    case Ship = 1
    case Bird = 2
    case Bullet = 4
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var ship : SKSpriteNode?
    
    private var contentCreated : Bool = false;
    private var touchInProgress : Bool = false;
    private var birdsAttacking : Bool = true;


    // optional protocol
    func didBegin(_ contact: SKPhysicsContact) {

//    func didBeginContact(contact: SKPhysicsContact!) {
//        print("A collision was detected!")
        if (contact.bodyA.categoryBitMask == CollisionType.Ship.rawValue && contact.bodyB.categoryBitMask == CollisionType.Bird.rawValue) {
//            print("The collision was between the Ship and a Bird")

            let bird = contact.bodyB.node
            if (bird?.parent == nil)
            {
                return
            }
            bird?.removeAllActions()
            bird?.removeFromParent()

            // stop other birds
            birdsAttacking = false;
            self.enumerateChildNodes(withName: "bird", using: {
                (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
                node.removeFromParent()
            })

            let prevTouchInProgres = touchInProgress;
            touchInProgress = false;
            self.explosion(pos: (ship?.position)!)

            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let move = SKAction.move(to: CGPoint(x: self.size.width/2, y: self.size.height/8), duration: 0.5)
            let fadeIn = SKAction.fadeIn(withDuration: 2)
            let firing = SKAction.run({
                self.touchInProgress = prevTouchInProgres
                self.birdsAttacking = true
            })
            ship?.run(SKAction.sequence([fadeOut, move, fadeIn, firing]))

        }
        else if ((contact.bodyA.categoryBitMask == CollisionType.Bird.rawValue && contact.bodyB.categoryBitMask == CollisionType.Bullet.rawValue)
            || (contact.bodyA.categoryBitMask == CollisionType.Bullet.rawValue && contact.bodyB.categoryBitMask == CollisionType.Bird.rawValue)) {
//            print("The collision was between a Bird and a Bullet")
            
            // TODO: simplify
            
            // blow up the bird
            let bird = contact.bodyA.node
            let bullet = contact.bodyB.node
            let explosionPosition = bird?.position
            
            // already removed, skip it
            if (bird?.parent == nil)
            {
                return
            }


            bird?.removeAllActions()
            bird?.removeFromParent()
            bullet?.removeAllActions()
            bullet?.removeFromParent()
            
            explosion(pos: explosionPosition!)
            
            
        }
    }

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
    
    
    func explosion(pos: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: "ExplosionParticle.sks")
        
        
//        let duration = Double((emitterNode?.numParticlesToEmit)!) / Double((emitterNode?.particleBirthRate)!) + Double((emitterNode?.particleLifetime)! + (emitterNode?.particleLifetimeRange)!/2)
        
        emitterNode!.particlePosition = pos
        self.addChild(emitterNode!)
//        emitterNode!.removeFromParent()
        self.run(SKAction.wait(forDuration: 2.0), completion: { emitterNode!.removeFromParent() })
//        self.run(SKAction.wait(forDuration: duration), completion: { emitterNode!.removeFromParent() })

        
//        let run = SKAction.run {
//            emitterNode?.run(<#T##action: SKAction##SKAction#>)
//        }
//        emitterNode.run(SKAction.sequence([, fly, delete]))

    }
    
    
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
    
    override func didMove(to view: SKView) {
        
        if (!contentCreated)
        {
            self.physicsWorld.contactDelegate = self

            self.anchorPoint = CGPoint(x: 0, y: 0)
            
        
//            let bgImage = SKSpriteNode(imageNamed: "background.png")
            let bgImage = SKSpriteNode(imageNamed: "star_fields.png")
            bgImage.zPosition = -5
        
            bgImage.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
            bgImage.size = self.size
            addChild(bgImage)
            
            ship = SKSpriteNode(imageNamed: "Spaceship.png")
            ship?.xScale = 0.25
            ship?.yScale = 0.25
//            ship?.size = CGSize(width: 100, height: 100)
            ship?.position = CGPoint(x: self.size.width/2, y: self.size.height/8)
            addChild(ship!)

            // add ship physics
            ship?.physicsBody = SKPhysicsBody(texture: (ship?.texture)!, size: (ship?.size)!)
            ship?.physicsBody?.isDynamic = false
            ship?.physicsBody?.affectedByGravity = false
            ship?.physicsBody?.categoryBitMask = CollisionType.Ship.rawValue
            ship?.physicsBody?.contactTestBitMask = CollisionType.Bird.rawValue
            ship?.physicsBody?.collisionBitMask = CollisionType.Bird.rawValue

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

        }
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }

    }
   

    func handleTouch(toPoint pos : CGPoint) {
        ship?.position.x = pos.x
//        self.fireBullet()
    }
    
    func setupShip() {
    }

    func fireBullet() {

        if (touchInProgress == false) {
            return
        }

        let bullet = SKSpriteNode(imageNamed: "bullet.png")
        bullet.zPosition = -1
        bullet.position = CGPoint(x: (ship?.position.x)!, y: (ship?.position.y)!)

        let move = SKAction.moveTo(y: self.size.height+50, duration: 1)
        let delete = SKAction.removeFromParent()
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

        if (birdsAttacking == false) {
            return
        }

        let bird = SKSpriteNode(imageNamed: "bird.png")
        bird.name = "bird"
        bird.xScale = 0.5
        bird.yScale = 0.5
//        let randomX = Int(arc4random_uniform(UInt32(Int(self.size.width))) + 1)

        let randomX = GKRandomSource.sharedRandom().nextInt(upperBound: Int(self.size.width))
        
        bird.position = CGPoint(x: randomX, y: Int(self.size.height - bird.size.height / 2))

        let spin = SKAction.rotate(byAngle: CGFloat(3*M_PI), duration: 0.5)
        let fly = SKAction.moveTo(y: 0, duration: 3)
        let delete = SKAction.removeFromParent()
        bird.run(SKAction.sequence([spin, fly, delete]))

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

//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//
        touchInProgress = true
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
        touchInProgress = false
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchInProgress = false
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
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
