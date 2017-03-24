//
// Created by Tom on 3/23/17.
// Copyright (c) 2017 Tom Patterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Ship {
    var shipSpriteNode: SKSpriteNode!

    init(gameScene: GameScene) {
        shipSpriteNode = SKSpriteNode(imageNamed: "Spaceship.png")
        shipSpriteNode.xScale = 0.25
        shipSpriteNode.yScale = 0.25
        shipSpriteNode.position = CGPoint(x: gameScene.size.width/2, y: shipSpriteNode.size.height+90)

        // hack for iPad - how to fix this?
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            shipSpriteNode.position.y += 100
        }

        // add ship physics
        shipSpriteNode.physicsBody = SKPhysicsBody(texture: (shipSpriteNode.texture)!, size: shipSpriteNode.size)
        shipSpriteNode.physicsBody?.isDynamic = false
        shipSpriteNode.physicsBody?.affectedByGravity = false
        shipSpriteNode.physicsBody?.categoryBitMask = CollisionType.Ship.rawValue
        shipSpriteNode.physicsBody?.contactTestBitMask = CollisionType.Bird.rawValue
        shipSpriteNode.physicsBody?.collisionBitMask = 0
    }

    func setXPos(x: CGFloat) {
        shipSpriteNode.position.x = x
    }

    func position() -> CGPoint {
        return shipSpriteNode.position
    }
}
