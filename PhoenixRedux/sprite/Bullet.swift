//
// Created by Tom on 3/23/17.
// Copyright (c) 2017 Tom Patterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Bullet {

    var bulletSpriteNode: SKSpriteNode!

    init(gameScene: GameScene, position: CGPoint) {
        bulletSpriteNode = SKSpriteNode(imageNamed: "bullet.png")
        bulletSpriteNode.zPosition = -1
        bulletSpriteNode.position = position

        let move = SKAction.moveTo(y: gameScene.size.height+50, duration: 1)
        let delete = SKAction.removeFromParent()
        gameScene.playSound(sound: SoundAction.ShipShot)
        bulletSpriteNode.run(SKAction.sequence([move, delete]))

        // physics
        bulletSpriteNode.physicsBody = SKPhysicsBody(texture: (bulletSpriteNode.texture)!, size: (bulletSpriteNode.size))
        bulletSpriteNode.physicsBody?.isDynamic = false
        bulletSpriteNode.physicsBody?.affectedByGravity = false
        bulletSpriteNode.physicsBody?.categoryBitMask = CollisionType.Bullet.rawValue
        bulletSpriteNode.physicsBody?.contactTestBitMask = CollisionType.Bird.rawValue
        bulletSpriteNode.physicsBody?.collisionBitMask = 0
    }
}
