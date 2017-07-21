//
//  SKMultilineLabel.swift
//  PhoenixRedux
//
//  Created by Tom Patterson on 7/20/17.
//  Copyright © 2017 Tom Patterson. All rights reserved.
//

import SpriteKit

class SKMultilineLabel: SKNode {
    //props
    var labelWidth:Int {didSet {update()}}
    var labelHeight:Int = 0
    var text:String {didSet {update()}}
    var fontName:String {didSet {update()}}
    var fontSize:CGFloat {didSet {update()}}
    var pos:CGPoint {didSet {update()}}
    var fontColor:SKColor {didSet {update()}}
    var leading:Int {didSet {update()}}
    var alignment:SKLabelHorizontalAlignmentMode {didSet {update()}}
    var dontUpdate = false
    var shouldShowBorder:Bool = false {didSet {update()}}
    //display objects
    var rect:SKShapeNode?
    var labels:[SKLabelNode] = []
    init(text:String, labelWidth:Int, pos:CGPoint, fontName:String="ChalkboardSE-Regular",fontSize:CGFloat=10,fontColor:SKColor=SKColor.black,leading:Int=10, alignment:SKLabelHorizontalAlignmentMode = .center, shouldShowBorder:Bool = false)
    {
        self.text = text
        self.labelWidth = labelWidth
        self.pos = pos
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.leading = leading
        self.shouldShowBorder = shouldShowBorder
        self.alignment = alignment
        
        super.init()
        
        self.update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //if you want to change properties without updating the text field,
    //  set dontUpdate to false and call the update method manually.
    func update() {
        if (dontUpdate) {return}
        if (labels.count>0) {
            for label in labels {
                label.removeFromParent()
            }
            labels = []
        }
        let separators = NSCharacterSet.whitespacesAndNewlines
        let lineSeparators = NSCharacterSet.newlines
        let paragraphs = text.components(separatedBy: lineSeparators)
        //    let paragraphs = text.componentsSeparatedByCharactersInSet(lineSeparators)
        
        var lineCount = 0
        for (_, paragraph) in paragraphs.enumerated() {
            let words = paragraph.components(separatedBy: separators)
            var finalLine = false
            var wordCount = -1
            while (!finalLine) {
                lineCount += 1
                var lineLength = CGFloat(0)
                var lineString = ""
                var lineStringBeforeAddingWord = ""
                
                // creation of the SKLabelNode itself
                let label = SKLabelNode(fontNamed: fontName)
                // name each label node so you can animate it if u wish
                label.name = "line\(lineCount)"
                label.horizontalAlignmentMode = alignment
                label.fontSize = fontSize
                label.fontColor = SKColor.white
                
                while lineLength < CGFloat(labelWidth)
                {
                    wordCount += 1
                    if wordCount > words.count-1
                    {
                        //label.text = "\(lineString) \(words[wordCount])"
                        finalLine = true
                        break
                    }
                    else
                    {
                        lineStringBeforeAddingWord = lineString
                        lineString = "\(lineString) \(words[wordCount])"
                        label.text = lineString
                        lineLength = label.frame.size.width
                    }
                }
                if lineLength > 0 {
                    wordCount -= 1
                    if (!finalLine) {
                        lineString = lineStringBeforeAddingWord
                    }
                    label.text = lineString
                    var linePos = pos
                    if (alignment == .left) {
                        linePos.x -= CGFloat(labelWidth / 2)
                    } else if (alignment == .right) {
                        linePos.x += CGFloat(labelWidth / 2)
                    }
                    linePos.y += CGFloat(-leading * lineCount)
                    // label.position = CGPointMake( linePos.x , linePos.y )
                    label.position = CGPoint(x: linePos.x , y: linePos.y )
                    self.addChild(label)
                    labels.append(label)
                    //println("was \(lineLength), now \(label.width)")
                }
            }
        }
        labelHeight = lineCount * leading
        showBorder()
    }
    
    func showBorder() {
        if (!shouldShowBorder) {return}
        if let rect = self.rect {
            self.removeChildren(in: [rect])
        }
        self.rect = SKShapeNode(rectOf: CGSize(width: labelWidth, height: labelHeight))
        if let rect = self.rect {
            rect.strokeColor = SKColor.white
            rect.lineWidth = 1
            rect.position = CGPoint(x: pos.x, y: pos.y - (CGFloat(labelHeight) / 2.0))
            self.addChild(rect)
        }
    }
}
