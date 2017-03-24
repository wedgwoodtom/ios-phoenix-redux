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


    init(from: SKScene) {
        // perform some initialization here
        scene = from
        createHUD()
    }

    func HUDNode() -> SKSpriteNode {
        return hud
    }

    func updateHUDForScoreDecrement() {
        score -= 200
        self.scoreNode.text = "\(score)"
    }

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
        // TODO: below should not be necessary.  However, without it, the lives are not drawn on the iPhone although it works as expected in the simulator
        drawRemaingLives(shipsLeft: shipsLeftList.count)
    }

    func resetHUD() {
        score = 0;
        self.scoreNode.text = "\(score)"
        drawRemaingLives(shipsLeft: shipsLeftList.count)
    }

    func drawRemaingLives(shipsLeft: Int) {
        // reset lives left
        let lifeSize = CGSize(width: hud.size.height-18, height: hud.size.height-18)
        hud.removeChildren(in: shipsLeftList)
        shipsLeftList.removeAll()

        for i in 0..<shipsLeft-1 {
            let tmpNode = SKSpriteNode(imageNamed: "Spaceship.png")
            shipsLeftList.append(tmpNode)
            tmpNode.size = lifeSize
            tmpNode.position=CGPoint(x: tmpNode.size.width * 1.3 * (1.0 + CGFloat(i)), y: (hud.size.height-5)/2)
            tmpNode.name = "shipLifeIcon"
            hud.addChild(tmpNode)
        }
    }

    func createHUD() {
        hud = SKSpriteNode()

        //hud.color = .black
        hud.size = CGSize(width: scene.size.width, height: scene.size.height * 0.05)

        hud.anchorPoint = CGPoint(x: 0, y: 0)
        hud.position = CGPoint(x: 0, y: scene.size.height-hud.size.height)
//        hud.position = CGPoint(x: 0, y: hud.size.height)
        // hack for iPad - how to fix this?
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            hud.position.y -= 175
        }
        scene.addChild(hud)

        // Display the current score
        self.score = 0
//        self.scoreNode.position = CGPoint(x: hud.size.width-hud.size.width * 0.1, y: 1)
        self.scoreNode.position = CGPoint(x: hud.size.width-hud.size.width * 0.1, y: 20)
        self.scoreNode.text = ""
        //self.scoreNode.fontSize = hud.size.height * 0.50
        self.scoreNode.fontName = "Helvetica Neue Medium"
        self.scoreNode.fontSize = 30
        //self.scoreNode.font = UIFont.boldSystemFontOfSize(hud.size.height * 0.50)
        self.scoreNode.fontColor = .red
        hud.addChild(self.scoreNode)
    }

}
