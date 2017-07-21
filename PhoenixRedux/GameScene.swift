//
//  GameScene.swift
//  PhoenixRedux
//
//  Created by Tom on 3/17/17.
//  Copyright © 2017 Tom Patterson. All rights reserved.
//
/**
    A work in progress for Lab Week - scratch your inner-Geek!
 **/

import SpriteKit
import GameplayKit
import Foundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ship: Ship!
    var hud: HeadsUpDisplay!
    var gameControls: GameControls!
    var collisionHandler: CollisionHandler!

    var contentCreated : Bool = false
    var gameState: GameState = GameState.NotStarted
    var touchIsDown: Bool = false

    // This method sets up the initial game screen, timers, and displays the game controls
    override func didMove(to view: SKView) {
        if (contentCreated) {
            return
        }

        preloadSounds()
        self.physicsWorld.contactDelegate = self
        self.anchorPoint = CGPoint(x: 0, y: 0)

        let bgImage = SKSpriteNode(imageNamed: "star_fields.png")
        bgImage.zPosition = -5
        bgImage.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        bgImage.size = self.size
        addChild(bgImage)

        hud = HeadsUpDisplay(from: self)
        addChild(hud.spriteNode())
        gameControls = GameControls(from: self)
        ship = Ship(gameScene: self)
        addChild(ship.shipSpriteNode)
        collisionHandler = CollisionHandler(scene: self)

        gameState = GameState.NotStarted
        playSound(sound: SoundAction.GameInit)
        gameControls.toggleGameControls(on: true)

        // start bird and bullet timers
        Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(self.fireBullet),
                userInfo: nil,
                repeats: true)

        Timer.scheduledTimer(
                timeInterval: 0.9,
                target: self,
                selector: #selector(self.spawnPhoenix),
                userInfo: nil,
                repeats: true)

        contentCreated = true
    }

    func startGame() {
        playSound(sound: SoundAction.GameStart)
        gameControls.toggleGameControls(on: false)
        hud.startGame()
        self.run(SKAction.wait(forDuration: 2.0), completion: { self.gameState = GameState.Running })
    }

    func endGame() {
        gameState = GameState.NotStarted
        gameControls.toggleGameControls(on: true)
        hud.endGame()
    }
    
    func showHighScores() {
        let myScore = hud.score
        let scoreClient = ScoreClient()
        scoreClient.submitScore(userId: "codeSith777", gameId: "phoenixRedux", score: myScore) { (scores: [Score]) in
            self.gameControls.showHighScores(scores: scores)
        }
    }

    func fireBullet() {

        if (touchIsDown == false || gameState != GameState.Running) {
            return
        }

        self.addChild(Bullet(gameScene: self, position: ship.position()).bulletSpriteNode)
    }

    func spawnPhoenix() {

        if (gameState != GameState.Running) {
            return
        }

        self.addChild(Phoenix(gameScene: self).birdSpriteNode)
    }

    func explosion(pos: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: "ExplosionParticle.sks")
        emitterNode!.particlePosition = pos
        self.addChild(emitterNode!)

        playSound(sound: SoundAction.BirdExplosion)
        self.run(SKAction.wait(forDuration: 2.0), completion: { emitterNode!.removeFromParent() })
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
            ship.setXPos(x: pos.x)
        }
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
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

        touchIsDown = false
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

    // Collision detection
    func didBegin(_ contact: SKPhysicsContact) {
        collisionHandler.handleContact(contact)
    }

    func preloadSounds() {
        // They are cached once loaded (or seem to be).  Think about wrapping all this sound fctn into a class
        for sound in SoundAction.all() {
            playSound(sound: sound, now: false)
        }
    }

    func playSound(sound: SoundAction, now: Bool = true) {
        if (now) {
            SKTAudio.sharedInstance().playSoundEffect(sound.rawValue)
        }
    }

}

