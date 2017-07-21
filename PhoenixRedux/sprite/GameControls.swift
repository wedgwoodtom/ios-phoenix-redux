//
// Created by Tom on 3/23/17.
// Copyright (c) 2017 Tom Patterson. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

class GameControls {

    private var titleLabel: SKLabelNode!
    private var titleBird: SKSpriteNode!
    private var titleStart: SKSpriteNode!
    private var gameOverLabel: SKLabelNode!
    private var highScoresLabel: SKLabelNode!
    private var scene: SKScene!
    private var topScoreIndex: Int

    init(from: SKScene) {
        scene = from

        // These controls are in the GameScene.sks file
        self.titleLabel = scene.childNode(withName: "titleLabel") as? SKLabelNode
        self.titleBird = scene.childNode(withName: "titleBird") as? SKSpriteNode
        self.titleStart = scene.childNode(withName: "titleStart") as? SKSpriteNode
        self.gameOverLabel = scene.childNode(withName: "gameOverLabel") as? SKLabelNode
        self.highScoresLabel = scene.childNode(withName: "highScoreLabel") as? SKLabelNode
        self.topScoreIndex = -1
    }

    func toggleGameControls(on: Bool = true) {

        let action = on ? SKAction.fadeIn(withDuration: 2.0) : SKAction.fadeOut(withDuration: 2.0)

        if let label = self.titleLabel {
            label.position = CGPoint(x: scene.size.width/2, y: scene.size.height/1.5)
            label.alpha = on ? 0.0 : 1.0
            label.run(action)

            if let titleBird = self.titleBird {
                titleBird.position = CGPoint(x: scene.size.width/2, y: label.position.y + titleBird.size.height)
                titleBird.alpha = on ? 0.0 : 1.0
                // hack for iPad
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    titleBird.position.y -= 100
                }
                titleBird.run(action)
            }

            if let titleStart = self.titleStart {
                titleStart.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
                titleStart.alpha = on ? 0.0 : 1.0
                titleStart.run(action)
                titleStart.name = "startButton"
            }

            if let highScoresLabel = self.highScoresLabel {
                highScoresLabel.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2 - 100)
                highScoresLabel.alpha = 0.0
                //if (!on) {
                    highScoresLabel.removeAllActions()
                //}
            }
            
            if (!on) {
                if let gameOverLabel = self.gameOverLabel {
                    gameOverLabel.position = CGPoint(x: scene.size.width/2, y:  scene.size.height + 200)
                }
            }
        }
    }

    func dropGameOverLabel() {
        gameOverLabel.position = CGPoint(x: scene.size.width/2, y:  scene.size.height + 200)
        gameOverLabel.run(SKAction.move(to: CGPoint(x: scene.size.width/2, y: scene.size.height/3.2), duration: 5.0))
    }
    
    func showHighScores(scores: [Score]) {
        topScoreIndex = -1
        let wait = SKAction.wait(forDuration: 3)
        let updateTopScore = SKAction.run {
            self.cycleThroughScores(scores: scores)
        }
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let sequence = SKAction.sequence([updateTopScore, wait, fadeOut])
        self.highScoresLabel.run(SKAction.repeatForever(sequence))
    }
    
    func cycleThroughScores(scores: [Score]) {
        topScoreIndex = topScoreIndex + 1
        if (topScoreIndex == scores.count) {
            topScoreIndex = 0
        }
        let score = scores[topScoreIndex]
        highScoresLabel.text = "#\(topScoreIndex+1) Pilot...\(score.id.padding(toLength: 12, withPad: ".", startingAt: 0))...\(score.score) Pts!!"
        highScoresLabel.alpha = 1.0
    }

}
