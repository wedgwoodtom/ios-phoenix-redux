//
// Created by Tom on 3/23/17.
// Copyright (c) 2017 Tom Patterson. All rights reserved.
//

import Foundation


enum SoundAction: String {
    case ShipShot = "shot1.wav"
    case BirdShot = "shot2.wav"
    case BirdGotAway = "shot4.mp3"
    case BirdExplosion = "explosion2.wav"
    case ShipExplosion = "ShipHit.wav"
    case GameOver = "gameOver.mp3"
    case GameStart = "gameStart.mp3"
    case GameInit = "gameInit.mp3"

    // TODO: Lame that I have to do this
    static func all() -> Array<SoundAction> {
        return [ShipShot, BirdShot, BirdExplosion, ShipExplosion, GameOver, GameStart, GameInit, BirdGotAway]
    }
}