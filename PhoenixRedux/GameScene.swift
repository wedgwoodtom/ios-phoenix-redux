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
    case GameOver = "gameOver.mp3"
    case GameStart = "gameStart.mp3"
    case GameInit = "gameInit.mp3"

    // TODO: Lame that I have to do this
    static func all() -> Array<Sound> {
        return [ShipShot, BirdShot, BirdExplosion, ShipExplosion, GameOver, GameStart, GameInit]
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
    case Over
//    case Paused
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var titleLabel: SKLabelNode?
    private var titleBird: SKSpriteNode?
    private var titleStart: SKSpriteNode?
    private var gameOverLabel: SKLabelNode?

    private var ship : SKSpriteNode?
    
    private var contentCreated : Bool = false

    private var gameState: GameState = GameState.NotStarted
    private var touchIsDown: Bool = false
    private var shipsLeft: Int = 2
    private var score: Int = 0
    var scoreNode = SKLabelNode()
    private var shipsLeftList = Array<SKSpriteNode>()
    // heads up display
    private var hud = SKSpriteNode()


    override func didMove(to view: SKView) {
        
        if (!contentCreated)
        {
            // Get label node from scene and store it for use later
            self.titleLabel = self.childNode(withName: "titleLabel") as? SKLabelNode
            self.titleBird = self.childNode(withName: "titleBird") as? SKSpriteNode
            self.titleStart = self.childNode(withName: "titleStart") as? SKSpriteNode
            self.gameOverLabel = self.childNode(withName: "gameOverLabel") as? SKLabelNode

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
                ship.physicsBody?.collisionBitMask = 0
            }

            gameState = GameState.NotStarted
            playSound(sound: Sound.GameInit)
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

            createHUD()
            
            contentCreated = true
        }
    }

    func toggleGameControls(on: Bool = true) {

        var action = on ? SKAction.fadeIn(withDuration: 2.0) : SKAction.fadeOut(withDuration: 2.0)

        if let label = self.titleLabel {
            label.position = CGPoint(x: self.size.width/2, y: self.size.height/1.5)
            label.alpha = on ? 0.0 : 1.0
            label.run(action)

            if let titleBird = self.titleBird {
                titleBird.position = CGPoint(x: self.size.width/2, y: label.position.y + titleBird.size.height)
                titleBird.alpha = on ? 0.0 : 1.0
                // hack for iPad
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    titleBird.position.y -= 100
                }
                titleBird.run(action)
            }

            if let titleStart = self.titleStart {
                titleStart.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
                titleStart.alpha = on ? 0.0 : 1.0
                titleStart.run(action)
                titleStart.name = "startButton"
            }

            if (!on) {
                if let gameOverLabel = self.gameOverLabel {
                    gameOverLabel.position = CGPoint(x: self.size.width/2, y:  self.size.height + 200)
                }
            }
            /*
             if (!on) {
                if let gameOverLabel = self.gameOverLabel {
                    gameOverLabel.alpha = 0.0
                    gameOverLabel.run(SKAction.fadeOut(withDuration: 2.0), completion: {
                        gameOverLabel.position = CGPoint(x: self.size.width/2, y:  self.size.height + 200)
                    })
                }
            }
            */

        }
    }

    func endGame() {
        toggleGameControls(on: true)
        gameState = GameState.NotStarted
        shipsLeft = 0;
    }

    func startGame() {
        playSound(sound: Sound.GameStart)
        toggleGameControls(on: false)
        shipsLeft = 3;
        resetHUD()
        self.run(SKAction.wait(forDuration: 2.0), completion: { self.gameState = GameState.Running })
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
        bullet.physicsBody?.collisionBitMask = 0
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
        bird.physicsBody?.collisionBitMask = 0
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
        //if (currentTime - self.timeOfLastMove < self.timePerMove) return;
        //var emitterToAdd   = emitter.copy() as SKEmitterNode
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
        let firing = SKAction.run({
            self.gameState = GameState.Running
        })

        // default actions
        var actions = [fadeOut, fadeIn, move, firing]
        shipsLeft -= 1
        if (shipsLeft == 0) {
            self.gameState = GameState.Over
            let gameOver = SKAction.playSoundFileNamed(Sound.GameOver.rawValue, waitForCompletion: true)
            let endGame = SKAction.run({
                self.endGame()
            })

            if let gameOverLabel = self.gameOverLabel {
                gameOverLabel.position = CGPoint(x: self.size.width/2, y:  self.size.height + 200)
                gameOverLabel.run(SKAction.move(to: CGPoint(x: self.size.width/2, y: self.size.height/4.5), duration: 5.0))
            }

            actions = [fadeOut, gameOver, fadeIn, move, endGame]
        }

        playSound(sound: Sound.ShipExplosion)
        updateHUDForShipDestroyed()
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
        explosion(pos: explosionPosition!)

        updateHUDForScore()
    }


    // TODO: Move to a class
    
    func updateHUDForScore() {
        score += 100
        self.scoreNode.text = "\(score)"
    }

    func updateHUDForShipDestroyed() {
        if shipsLeftList.count == 0 {
            return
        }
        let last: SKSpriteNode = shipsLeftList.removeLast()
        last.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.5), SKAction.removeFromParent()]))
    }

    func resetHUD() {
        score = 0;
        self.scoreNode.text = "\(score)"

        // reset lives left
        let lifeSize = CGSize(width: hud.size.height-18, height: hud.size.height-18)
        shipsLeftList.removeAll()
        for i in 0..<shipsLeft-1 {
            let tmpNode = SKSpriteNode(imageNamed: "Spaceship.png")
            shipsLeftList.append(tmpNode)
            tmpNode.size = lifeSize
            tmpNode.position=CGPoint(x: tmpNode.size.width * 1.3 * (1.0 + CGFloat(i)), y: (hud.size.height-5)/2)
            hud.addChild(tmpNode)
        }
    }
    
    func createHUD() {
        //var hud = SKSpriteNode(color: .black, size: CGSize(width: self.size.width, height: self.size.height * 0.05)
        //let hud = SKSpriteNode()
        //hud.color = .black
        hud.size = CGSize(width: self.size.width, height: self.size.height * 0.05)
        hud.anchorPoint = CGPoint(x: 0, y: 0)
        //hud.position = CGPoint(x: 0, y: self.size.height-hud.size.height)
        hud.position = CGPoint(x: 0, y: hud.size.height)
        self.addChild(hud)

        // Display the current score
        self.score = 0
        self.scoreNode.position = CGPoint(x: hud.size.width-hud.size.width * 0.1, y: 1)
        self.scoreNode.text = "0"
        //self.scoreNode.fontSize = hud.size.height * 0.50
        self.scoreNode.fontName = "Helvetica Neue Medium"
        self.scoreNode.fontSize = 25
        //self.scoreNode.font = UIFont.boldSystemFontOfSize(hud.size.height * 0.50)
        self.scoreNode.fontColor = .red
        hud.addChild(self.scoreNode)
    }


}

