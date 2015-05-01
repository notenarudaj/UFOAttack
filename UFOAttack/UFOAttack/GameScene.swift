//
//  GameScene.swift
//  UFOAttack
//
//  Created by note on 4/29/2558 BE.
//  Copyright (c) 2558 Narudaj. All rights reserved.
//

import AVFoundation
import SpriteKit

class GameScene: SKScene {
    
    let lower_x_bound: CGFloat = 0.0
    let lower_y_bound: CGFloat = 0.0
    var higher_x_bound: CGFloat = 0.0
    var higher_y_bound: CGFloat = 0.0
    
    var star_layer: [[SKSpriteNode]] = []
    var star_layer_speed: [CGFloat] = []
    var star_layer_color: [SKColor] = []
    var star_layer_count: [Int] = []
    
    var x_direction: CGFloat = 1.0
    var y_direction: CGFloat = -1.0
    
    var soundBG = AVAudioPlayer()
    var soundBreak = AVAudioPlayer()
    var soundFailure = AVAudioPlayer()

    var level = 1
    var score = 0
    var point = 0
    var health = 1
    var gameOver: Bool?
    var maxNumberOfEnemy: Int?
    var currentNumberOfEnemy: Int?
    var timeBetweenEnemy: Double?
    var moveSpeed = 5.0
    let moveFactor = 1.01
    
    var now: NSDate?
    var nextTime: NSDate?
    var healthLabel: SKLabelNode?
    var levelLabel: SKLabelNode?
    var endGameLabel: SKLabelNode?
    var messageLabel: SKLabelNode?
    var buttonGame: SKSpriteNode?
    
    var ufos: NSMutableArray = []
    
    override func didMoveToView(view: SKView) {
        initial(1)
    }
    
    func initial(levelNumber: Int) {
        
        self.removeAllChildren()
        ufos.removeAllObjects()
        level = levelNumber
        
        initialScene()
        
        soundBackground()
        soundTouch()
        soundEnd()
        
        initialGame()
    }
    
    func initialScene() {
        
        self.backgroundColor = SKColor.blackColor()
        
        higher_x_bound = self.frame.width
        higher_y_bound = self.frame.height
        
        var dummySprite = SKSpriteNode(imageNamed: "star")
        
        star_layer = [[dummySprite], [dummySprite], [dummySprite]]
        
        star_layer_count.append(50)
        star_layer_speed.append(0.9)
        star_layer_color.append(SKColor.whiteColor())
        
        star_layer_count.append(50)
        star_layer_speed.append(0.6)
        star_layer_color.append(SKColor.yellowColor())
        
        star_layer_count.append(50)
        star_layer_speed.append(0.3)
        star_layer_color.append(SKColor.redColor())
        
        for starLayer in 0...2 {
            
            for index in 1...star_layer_count[starLayer] {
                
                let x_position = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * higher_x_bound
                let y_position = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * higher_y_bound
                
                let sprite = SKSpriteNode(imageNamed: "star")
                sprite.position = CGPointMake(x_position, y_position)
                
                sprite.colorBlendFactor = 1.0
                sprite.color = star_layer_color[starLayer]
                star_layer[starLayer].append(sprite)
                self.addChild(sprite)
            }
        }
    }
    
    func soundBackground() {
        
        let path = NSBundle.mainBundle().pathForResource("BgSound", ofType: "wav")
        var pathURL = NSURL(fileURLWithPath: path!)
        soundBG = AVAudioPlayer(contentsOfURL: pathURL, error: nil)
        soundBG.prepareToPlay()
        soundBG.numberOfLoops = -1
        soundBG.volume = 1.0
    }
    
    func soundTouch() {
        
        let path = NSBundle.mainBundle().pathForResource("break", ofType: "wav")
        var pathURL = NSURL(fileURLWithPath: path!)
        soundBreak = AVAudioPlayer(contentsOfURL: pathURL, error: nil)
        soundBreak.prepareToPlay()
        soundBreak.numberOfLoops = 0
        soundBreak.volume = 0.3
    }
    
    func soundEnd() {
        
        let path = NSBundle.mainBundle().pathForResource("Failure", ofType: "wav")
        var pathURL = NSURL(fileURLWithPath: path!)
        soundFailure = AVAudioPlayer(contentsOfURL: pathURL, error: nil)
        soundFailure.prepareToPlay()
        soundFailure.numberOfLoops = 0
        soundFailure.volume = 0.3
    }
    
    func initialGame() {
        
        score = 0
        gameOver = false
        maxNumberOfEnemy = 5
        currentNumberOfEnemy = 0
        timeBetweenEnemy = 1.0
        moveSpeed = 5.0
        health = 10 * level
        nextTime = NSDate()
        now = NSDate()
        
        healthLabel = SKLabelNode(fontNamed: "System")
        healthLabel?.text = "Health: \(health)"
        healthLabel?.fontSize = 24
        healthLabel?.fontColor = SKColor.redColor()
        healthLabel?.position = CGPoint(x: 60, y: 5)
        self.addChild(healthLabel!)
        
        levelLabel = SKLabelNode(fontNamed: "System")
        levelLabel?.text = "Level is : \(level)"
        levelLabel?.fontSize = 24
        levelLabel?.fontColor = SKColor.redColor()
        levelLabel?.position = CGPoint(x: frame.width - 70, y: 5)
        self.addChild(levelLabel!)
        
        soundBG.play()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            
            if let theName = self.nodeAtPoint(location).name {
                
                if theName == "ufo" {
                    
                    soundBreak.play()
                    self.removeChildrenInArray([self.nodeAtPoint(location)])
                    ufos.removeObject(self.nodeAtPoint(location))
                    currentNumberOfEnemy? -= 1
                    score += 1
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            
            if let theName = self.nodeAtPoint(location).name {
                
                if theName == "buttonGame" {
                    
                    if level == 1 {
                        initial(2)
                    } else {
                        
                        let skView = SKView(frame: frame)
                        let scene = MainScene(size: skView.bounds.size)
                        
                        view?.presentScene(scene, transition: SKTransition.flipHorizontalWithDuration(1.0))
                    }
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {

        for index in 0...2 {
            
            moveSingleLayer(star_layer[index], speed: star_layer_speed[index])
        }
        
        gameRuntime()
    }
    
    func moveSingleLayer(star_layer: [SKSpriteNode], speed: CGFloat) {
        
        var sprite: SKSpriteNode
        var new_x: CGFloat = 0.0
        var new_y: CGFloat = 0.0
        
        for index in 0...star_layer.count-1 {
            
            sprite = star_layer[index]
            new_x = sprite.position.x + x_direction * speed
            new_y = sprite.position.y + y_direction * speed
            
            sprite.position = boundCheck(CGPointMake(new_x, new_y))
        }
    }
    
    func boundCheck(position: CGPoint) -> CGPoint {
        
        var x = position.x
        var y = position.y
        
        if x < 0 {
            x += higher_x_bound
        }
        
        if y < 0 {
            y += higher_y_bound
        }
        
        if x > higher_x_bound {
            x -= higher_x_bound
        }
        
        if y > higher_y_bound {
            y -= higher_y_bound
        }
        
        return CGPointMake(x, y)
    }
    
    func gameRuntime() {
        
        healthLabel?.text = "Health: \(health)"
        now = NSDate()
        
        if (currentNumberOfEnemy < maxNumberOfEnemy && now?.timeIntervalSince1970 > nextTime?.timeIntervalSince1970 && health > 0) {
            
            nextTime = now?.dateByAddingTimeInterval(NSTimeInterval(timeBetweenEnemy!))
            
            var newX = Int(arc4random() % UInt32(self.frame.width))
            var newY = Int(self.frame.height + 10)
            
            if newX < 100 {
                newX = 100
            } else if newX > Int(frame.width - 50) {
                newX = Int(frame.width - 50)
            }
            
            var position = CGPoint(x: newX, y: newY)
            
            if level == 2 {
                newX = Int(arc4random() % UInt32(self.frame.width))
            }
            
            var destination = CGPoint(x: newX, y: 0)
            
            createEnemy(position, destination: destination)
            
            if moveSpeed >= 1.70000000000000 {
                moveSpeed = moveSpeed / moveFactor
            }
            if timeBetweenEnemy >= 0.200000000000000 {
                timeBetweenEnemy = timeBetweenEnemy! / moveFactor
            }
        }
        
        checkIfEnemyReachTheBottom()
        checkIfGameIsEnd()
    }
    
    func createEnemy(position: CGPoint, destination: CGPoint) {
        
        let enemy = arc4random_uniform(8)
        
        let sprite = SKSpriteNode(imageNamed: "ufo\(enemy)")
        sprite.name = "ufo"
        sprite.xScale = 0.3
        sprite.yScale = 0.3
        sprite.position = position
        
        let duration = NSTimeInterval(moveSpeed)
        let action = SKAction.moveTo(destination, duration: duration)
        sprite.runAction(SKAction.repeatActionForever(action))
        
        let blinkIn = SKAction.scaleXTo(0.3, duration: 0.20)
        let blinkOut = SKAction.scaleXTo(0.4, duration: 0.20)
        let blink = SKAction.sequence([blinkIn, blinkOut])
        let blinkRepeat = SKAction.repeatActionForever(blink)
        sprite.runAction(blinkRepeat, withKey: "blink")
        
        currentNumberOfEnemy? += 1
        self.addChild(sprite)
        ufos.addObject(sprite)
    }
    
    func checkIfEnemyReachTheBottom() {
        
        for ufo in ufos {
            
            var sprite = ufo as SKSpriteNode
            
            if sprite.position.y == 0 {
                
                self.removeChildrenInArray([ufo])
                ufos.removeObject(sprite)
                currentNumberOfEnemy? -= 1
                
                if gameOver == false {
                    health -= 1
                }
            }
        }
    }
    
    func checkIfGameIsEnd() {
        
        if health <= 0 && gameOver == false {
            
            soundBG.stop()
            soundFailure.play()
            point += (level * 100) * score
            gameOver = true
            
            showGameEndScreen()
        }
    }
    
    func showGameEndScreen() {
        
        var msg = ""
        if level == 1 {
            msg = "End Game Level 1!"
        } else {
            msg = "End Game Level 2!"
        }
        
        endGameLabel = SKLabelNode(fontNamed: "System")
        endGameLabel?.text = "\(msg) Point: \(point)"
        endGameLabel?.fontColor = SKColor.yellowColor()
        endGameLabel?.fontSize = 30
        endGameLabel?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + 20)
        self.addChild(endGameLabel!)
        
        messageLabel = SKLabelNode(fontNamed: "System")
        messageLabel?.fontColor = SKColor.yellowColor()
        messageLabel?.fontSize = 30
        messageLabel?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - 30)
        
        buttonGame = SKSpriteNode(imageNamed: "ButtonGame")
        buttonGame?.name = "buttonGame"
        buttonGame?.size = CGSize(width: frame.width * 0.20, height: frame.height * 0.30)
        buttonGame?.position = CGPoint(x: CGRectGetMidX(frame), y: frame.height * 0.82)
        addChild(buttonGame!)
        
        if level == 1 {
            messageLabel?.text = "Play Next Level Is Touch Button"
        } else {
            messageLabel?.text = "Mission Complete"
        }
        self.addChild(messageLabel!)
    }
    
    class func scene(size:CGSize) -> GameScene {
        
        return GameScene(size: size)
    }
}
