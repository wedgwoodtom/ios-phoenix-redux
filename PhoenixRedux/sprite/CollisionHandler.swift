//
// Created by Tom on 3/23/17.
// Copyright (c) 2017 Tom Patterson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class CollisionHandler {

    var gameScene: GameScene!

    init(scene: GameScene) {
        gameScene = scene
    }

    func handleContact(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == CollisionType.Ship.rawValue && contact.bodyB.categoryBitMask == CollisionType.Bird.rawValue) {
            let bird = contact.bodyB.node
            handleCollision(bird: bird, ship: gameScene.ship.shipSpriteNode)
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

        gameScene.gameState = GameState.ShipDestroyed
        gameScene.enumerateChildNodes(withName: "bird", using: {
            (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            node.removeFromParent()
        })

        gameScene.explosion(pos: (ship?.position)!)

        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let move = SKAction.move(to: CGPoint(x: gameScene.size.width/2, y: (ship?.position.y)!), duration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 1.5)
        let firing = SKAction.run({
            self.gameScene.gameState = GameState.Running
        })

        gameScene.playSound(sound: SoundAction.ShipExplosion)
        // default actions
        var actions = [fadeOut, fadeIn, move, firing]
        if (gameScene.hud.shipDestroyed()) {
            gameScene.gameState = GameState.Over
            let gameOver = SKAction.playSoundFileNamed(SoundAction.GameOver.rawValue, waitForCompletion: true)
            let endGame = SKAction.run({
                self.gameScene.endGame()
            })
            let showHighScores = SKAction.run({
                self.gameScene.showHighScores()
            })

            gameScene.gameControls.dropGameOverLabel()
            actions = [fadeOut, gameOver, fadeIn, move, endGame, showHighScores]
        }

        ship?.run(SKAction.sequence(actions))
    }

    func handleCollision(bird: SKNode?, bullet: SKNode?) {

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
        gameScene.explosion(pos: explosionPosition!)

        gameScene.hud.scoreIncrement()
    }
}
