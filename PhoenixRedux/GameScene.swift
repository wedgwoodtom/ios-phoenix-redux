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

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var ship : SKSpriteNode?
    
    private var contentCreated : Bool = false;
    private var touchInProgress : Bool = false;


    override func didMove(to view: SKView) {
        
        if (!contentCreated)
        {
            self.anchorPoint = CGPoint(x: 0, y: 0)
            
        
            let bgImage = SKSpriteNode(imageNamed: "background.png")
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
        
        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//            
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
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
    }

    func spawnPhoenix() {
        let bird = SKSpriteNode(imageNamed: "bird.png")
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
