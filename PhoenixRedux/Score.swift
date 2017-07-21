//
//  Score.swift
//  TestAccessScoreService
//
//  Created by Tom Patterson on 7/20/17.
//  Copyright © 2017 Tom Patterson. All rights reserved.
//

import Foundation

public class Score {
    public var id: String
    public var score: Int
    
    public init(id: String, score: Int) {
        self.id = id
        self.score = score
    }
}
