//
// Created by Tom Patterson on 3/23/17.
// Copyright (c) 2017 Tom Patterson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class HeadsUpDisplay {

    private var score: Int = 0
    var scoreNode = SKLabelNode()
    private var shipsLeftList = Array<SKSpriteNode>()
    // heads up display
    private var hud: SKSpriteNode!
    private var scene: SKScene!
    private var shipsLeft: Int!


    init(from: SKScene) {
        // perform some initialization here
        scene = from
        shipsLeft = 3

        hud = SKSpriteNode()
        hud.size = CGSize(width: scene.size.width, height: scene.size.height * 0.05)

        hud.anchorPoint = CGPoint(x: 0, y: 0)
        hud.position = CGPoint(x: 0, y: scene.size.height-hud.size.height)
//        hud.position = CGPoint(x: 0, y: hud.size.height)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            hud.position.y -= 175
        }

        // Display the current score
        score = 0
        //scoreNode.position = CGPoint(x: hud.size.width-hud.size.width * 0.1, y: 1)
        scoreNode.position = CGPoint(x: hud.size.width-hud.size.width * 0.1, y: 20)
        scoreNode.text = ""
        //scoreNode.fontSize = hud.size.height * 0.50
        scoreNode.fontName = "Helvetica Neue Medium"
        scoreNode.fontSize = 30
        //scoreNode.font = UIFont.boldSystemFontOfSize(hud.size.height * 0.50)
        scoreNode.fontColor = .red
        hud.addChild(scoreNode)
    }

    func spriteNode() -> SKSpriteNode {
        return hud
    }

    func endGame() {
        shipsLeft = 0;
    }

    func startGame() {
        shipsLeft = 3;
        reDrawRemaingLives()
    }

    func scoreDecrement() {
        score -= 200
        scoreNode.text = "\(score)"
    }

    func scoreIncrement() {
        score += 100
        scoreNode.text = "\(score)"
    }

    // return true if the game is over
    func shipDestroyed()  -> Bool {
        shipsLeft = shipsLeft - 1
        if shipsLeftList.count == 0 {
            return true
        }

        let last: SKSpriteNode = shipsLeftList.removeLast()
        last.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.5), SKAction.removeFromParent()]))
        // TODO: below should not be necessary.  However, without it, the lives are not drawn on the iPhone although it works as expected in the simulator
        reDrawRemaingLives()

        return false
    }

    func reset() {
        score = 0;
        shipsLeft = 3
        scoreNode.text = "\(score)"
        reDrawRemaingLives()
    }

    func reDrawRemaingLives() {
        // reset lives left
        let lifeSize = CGSize(width: hud.size.height-18, height: hud.size.height-18)
        hud.removeChildren(in: shipsLeftList)
        shipsLeftList.removeAll()

        if (shipsLeft == 0) {
            return
        }

        for i in 0..<shipsLeft-1 {
            let tmpNode = SKSpriteNode(imageNamed: "Spaceship.png")
            shipsLeftList.append(tmpNode)
            tmpNode.size = lifeSize
            tmpNode.position=CGPoint(x: tmpNode.size.width * 1.3 * (1.0 + CGFloat(i)), y: (hud.size.height-5)/2)
            tmpNode.name = "shipLifeIcon"
            hud.addChild(tmpNode)
        }
    }



}
