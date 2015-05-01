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
    
    // ส่วนของหน้าจอ ========================================
    // ขอบเขตหน้าจอ
    let lower_x_bound: CGFloat = 0.0
    let lower_y_bound: CGFloat = 0.0
    var higher_x_bound: CGFloat = 0.0
    var higher_y_bound: CGFloat = 0.0
    
    // Star Layer One Properties
    var star_layer: [[SKSpriteNode]] = []   // Array 2 มิติ
    var star_layer_speed: [CGFloat] = []
    var star_layer_color: [SKColor] = []
    var star_layer_count: [Int] = []
    
    // ทิศทางการเลื่อน
    var x_direction: CGFloat = 1.0      // แนวนอน
    var y_direction: CGFloat = -1.0     // แนวตรง
    
    // เสียง
    var soundBG = AVAudioPlayer()
    var soundBreak = AVAudioPlayer()
    var soundFailure = AVAudioPlayer()
    // ===================================================
    
    
    // ส่วนของตัวเกมส์ =======================================
    var level = 1
    var score = 0                       // เต้มในแต่ละด่าน
    var point = 0                       // คะแนนรวม
    var health = 1
    var gameOver: Bool?
    var maxNumberOfEnemy: Int?
    var currentNumberOfEnemy: Int?
    var timeBetweenEnemy: Double?       // เวลาในการเกิด
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
    // ===================================================
    
    override func didMoveToView(view: SKView) {

        // จะต้องเริ่มเล่นด้วย Level 1 เสมอ
        initial(1)
    }
    
    func initial(levelNumber: Int) {
        
        self.removeAllChildren()
        ufos.removeAllObjects()
        level = levelNumber
        
        // สร้างฉาก
        initialScene()
        
        // สร้างเสียง
        soundBackground()
        soundTouch()
        soundEnd()
        
        // ส่วนของการสร้างเกมส์
        initialGame()
    }
    
    func initialScene() {
        
        // กำหนดสีหน้าจอ
        self.backgroundColor = SKColor.blackColor()
        
        // กำหนดขอบหน้าจอ
        higher_x_bound = self.frame.width
        higher_y_bound = self.frame.height
        
        // สร้าง Dummy Sprite
        var dummySprite = SKSpriteNode(imageNamed: "star")
        
        // สร้าง Star 3 Layer
        star_layer = [[dummySprite], [dummySprite], [dummySprite]]
        
        // กำหนดคุณสมบัติ Layer 0
        star_layer_count.append(50)
        star_layer_speed.append(0.9)
        star_layer_color.append(SKColor.whiteColor())
        
        // กำหนดคุณสมบัติ Layer 1
        star_layer_count.append(50)
        star_layer_speed.append(0.6)
        star_layer_color.append(SKColor.yellowColor())
        
        // กำหนดคุณสมบัติ Layer 2
        star_layer_count.append(50)
        star_layer_speed.append(0.3)
        star_layer_color.append(SKColor.redColor())
        
        for starLayer in 0...2 {
            
            for index in 1...star_layer_count[starLayer] {
                
                // สุ่มตำแหน่งของดาว (arc4random() = 10 หลัก) (UINT32_MAX = ค่าสูงสุดของ UInt32)
                // นำมาหาญกันจะได้เลขทศนิยม 6 ตำแหน่ง คูณกับขอบคงหน้าจอเพื่อให้ได้ความละเอียดของตำแหน่ง
                let x_position = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * higher_x_bound
                let y_position = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * higher_y_bound
                
                let sprite = SKSpriteNode(imageNamed: "star")
                sprite.position = CGPointMake(x_position, y_position)
                
                // การตั้งค่าสี Star ที่ถูกต้อง ใน Layer
                sprite.colorBlendFactor = 1.0               // ความเข้มของสี
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
        
        // สร้าง Label ในการแสดงพลังชีวิต
        healthLabel = SKLabelNode(fontNamed: "System")
        healthLabel?.text = "Health: \(health)"
        healthLabel?.fontSize = 24
        healthLabel?.fontColor = SKColor.redColor()
        healthLabel?.position = CGPoint(x: 60, y: 5)
        self.addChild(healthLabel!)
        
        // สร้าง Label ในการแสดง Level ที่กำลังเล่น
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
            
            // การเคลื่อนที่ของดวงดาว
            moveSingleLayer(star_layer[index], speed: star_layer_speed[index])
        }
        
        // ส่วนการจัดการส่วนต่างๆในเกมส์
        gameRuntime()
    }
    
    func moveSingleLayer(star_layer: [SKSpriteNode], speed: CGFloat) {
        
        var sprite: SKSpriteNode
        var new_x: CGFloat = 0.0
        var new_y: CGFloat = 0.0
        
        for index in 0...star_layer.count-1 {
            
            sprite = star_layer[index]
            new_x = sprite.position.x + x_direction * speed         // ได้เลข ###.12 หลัก
            new_y = sprite.position.y + y_direction * speed         // ได้เลข ###.12 หลัก
            
            // จะต้องทำการตรวจสอบ Position เพื่อให้ได้ค่าที่เหมาะสม
            sprite.position = boundCheck(CGPointMake(new_x, new_y))
        }
    }
    
    // การตรวจสอบขอบของหน้าจอ
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
        
        // 1. ถ้าจำนวนศัตรูปัจจุบัน น้อยกว่า จำนวนสูงสุดของศัตรู
        // 2. ณเวลาปัจจุบัยต้อง มากกว่า เวลาต่อไปที่ได้จากการคำนวณ
        // 3. พลังชีวิตต้อง มากกว่า 0
        if (currentNumberOfEnemy < maxNumberOfEnemy && now?.timeIntervalSince1970 > nextTime?.timeIntervalSince1970 && health > 0) {
            
            // คำนวณเวลาต่อไปที่จะใช้สร้าง Enemy
            nextTime = now?.dateByAddingTimeInterval(NSTimeInterval(timeBetweenEnemy!))
            
            var newX = Int(arc4random() % UInt32(self.frame.width))     // ความกว้างของหน้าจอ 1024
            var newY = Int(self.frame.height + 10)                      // เลยหน้าจอไป 10
            
            // ตรวจสอบตำแหน่งขอบหน้าจอ
            if newX < 100 {
                newX = 100
            } else if newX > Int(frame.width - 50) {
                newX = Int(frame.width - 50)
            }
            // =======================
            
            var position = CGPoint(x: newX, y: newY)
            
            if level == 2 {
                newX = Int(arc4random() % UInt32(self.frame.width))
            }
            
            var destination = CGPoint(x: newX, y: 0)
            
            // ทำการสร้างศัตรู
            createEnemy(position, destination: destination)
            
            if moveSpeed >= 1.70000000000000 {
                moveSpeed = moveSpeed / moveFactor                          // ความเร็วจะเพิ่มตามจำนวน Enemy
            }
            if timeBetweenEnemy >= 0.200000000000000 {
                timeBetweenEnemy = timeBetweenEnemy! / moveFactor           // คำนวณเวลาระหว่าง Enemy
            }
        }
        
        // ตรวจสอบการถึงข่างล่างของศัตรู
        checkIfEnemyReachTheBottom()
        // ตรวจสอบการจบเกมส์
        checkIfGameIsEnd()
    }
    
    // สร้างศัตรู
    func createEnemy(position: CGPoint, destination: CGPoint) {
        
        // สุ่มศัตรู 0 - 8
        let enemy = arc4random_uniform(8)
        
        let sprite = SKSpriteNode(imageNamed: "ufo\(enemy)")
        sprite.name = "ufo"
        sprite.xScale = 0.3
        sprite.yScale = 0.3
        sprite.position = position
        
        // กำหนดระยะเวลา
        let duration = NSTimeInterval(moveSpeed)
        // กำหนดตำแหน่งการเคลื่อนที่ ภายในระยะเวลา
        let action = SKAction.moveTo(destination, duration: duration)
        // ให้ Action ทำงาน
        sprite.runAction(SKAction.repeatActionForever(action))
        
        // การทำให้ UFO ยืดๆ หดๆ
        let blinkIn = SKAction.scaleXTo(0.3, duration: 0.20)
        let blinkOut = SKAction.scaleXTo(0.4, duration: 0.20)
        let blink = SKAction.sequence([blinkIn, blinkOut])
        let blinkRepeat = SKAction.repeatActionForever(blink)
        sprite.runAction(blinkRepeat, withKey: "blink")
        
        currentNumberOfEnemy? += 1
        self.addChild(sprite)
        ufos.addObject(sprite)
    }
    
    // ตรวจสอบการออกจากหน้าจอของ UFO
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
            
            // ส่วนการแสดงผลหลังจบเกมส์
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
        
        // ส่วนแสดงข้อความการจบเกมส์ และ บอกคะแนนในด่านนั้น
        endGameLabel = SKLabelNode(fontNamed: "System")
        endGameLabel?.text = "\(msg) Point: \(point)"
        endGameLabel?.fontColor = SKColor.yellowColor()
        endGameLabel?.fontSize = 30
        endGameLabel?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + 20)
        self.addChild(endGameLabel!)
        
        // ส่วนแสดงข้อความช่วยเหลือผู้เล่น
        messageLabel = SKLabelNode(fontNamed: "System")
        messageLabel?.fontColor = SKColor.yellowColor()
        messageLabel?.fontSize = 30
        messageLabel?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - 30)
        
        // ตัวสร้างปุ่มกด
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
    
    // Static Function ที่ใช้สร้างฉากการเล่นเกมส์
    class func scene(size:CGSize) -> GameScene {
        
        return GameScene(size: size)
    }
}
