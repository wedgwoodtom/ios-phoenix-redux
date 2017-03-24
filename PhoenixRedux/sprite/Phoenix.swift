//
// Created by Tom on 3/23/17.
// Copyright (c) 2017 Tom Patterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Phoenix {

    var birdSpriteNode: SKSpriteNode!

    init(gameScene: GameScene) {
        birdSpriteNode = SKSpriteNode(imageNamed: "bird.png")
        birdSpriteNode.name = "bird"
        birdSpriteNode.xScale = 0.75
        birdSpriteNode.yScale = 0.75

        // create more random path
        let minX = Double(0 + birdSpriteNode.size.width)
        let maxX = Double(gameScene.size.width - birdSpriteNode.size.width)
        let minY = Double(0 - birdSpriteNode.size.height / 2)
        let maxY = Double(gameScene.size.height - birdSpriteNode.size.height / 2)
        let x0 = Double(GKRandomSource.sharedRandom().nextInt(upperBound: Int(gameScene.size.width)))
        let y0 = Double(gameScene.size.height - birdSpriteNode.size.height / 2)
        let x1 = maxX
        let y1 = Double(GKRandomSource.sharedRandom().nextInt(upperBound: Int(maxY)))
        let x2 = minX
        let y2 = Double(GKRandomSource.sharedRandom().nextInt(upperBound: Int(maxY)))
        let x3 = Double(GKRandomSource.sharedRandom().nextInt(upperBound: Int(gameScene.size.width)))
        let y3 = minY

        birdSpriteNode.position = CGPoint(x: x0, y: y0)
        let fly1 = SKAction.move(to: CGPoint(x: x1, y: y1), duration: 1)
        let fly2 = SKAction.move(to: CGPoint(x: x2, y: y2), duration: 1)
        let fly3 = SKAction.move(to: CGPoint(x: x3, y: y3), duration: 1)
        let delete = SKAction.removeFromParent()
        //bird.run(SKAction.sequence([fly1, fly2, fly3, delete]))
        birdSpriteNode.run(SKAction.sequence([fly1, fly2, fly3, delete]), completion: {
            gameScene.playSound(sound: SoundAction.BirdGotAway)
            gameScene.hud.scoreDecrement()
        }
        )

        // physics
        birdSpriteNode.physicsBody = SKPhysicsBody(texture: (birdSpriteNode.texture)!, size: (birdSpriteNode.size))
        birdSpriteNode.physicsBody?.isDynamic = true
        birdSpriteNode.physicsBody?.affectedByGravity = false
        birdSpriteNode.physicsBody?.categoryBitMask = CollisionType.Bird.rawValue
        birdSpriteNode.physicsBody?.contactTestBitMask = CollisionType.Bullet.rawValue
        birdSpriteNode.physicsBody?.collisionBitMask = 0
    }

}
