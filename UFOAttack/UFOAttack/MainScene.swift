//
//  MainScene.swift
//  UFOAttack
//
//  Created by note on 4/30/2558 BE.
//  Copyright (c) 2558 Narudaj. All rights reserved.
//

import AVFoundation
import SpriteKit

class MainScene: SKScene {
    
    var soundBG: AVAudioPlayer?
    var soundButton = AVAudioPlayer()
    
    override func didMoveToView(view: SKView) {
        
        // สร้างองค์ประกอบต่างๆ
        initial()
        
        // สร้างเสียง
        soundBackground()
        soundTouch()
    }
    
    func initial() {
        
        // ส่วนของการสร้างพื้นหลัง
        let background = SKSpriteNode(imageNamed: "bg.jpg")
        background.name = "background"
        background.size = CGSize(width: frame.width, height: frame.height)
        background.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        addChild(background)
        
        // ส่วนของการสร้าง Logo
        let logo = SKSpriteNode(imageNamed: "logo.png")
        logo.name = "logo"
        logo.size = CGSize(width: frame.width * 0.2, height: frame.height * 0.3)
        logo.position = CGPoint(x: frame.width * 0.20, y: frame.height * 0.73)
        addChild(logo)
        
        // ส่วนของการสร้างชื่อเกมส์
        let nameGame = SKSpriteNode(imageNamed: "UFOAttack.png")
        nameGame.name = "nameGame"
        nameGame.size = CGSize(width: frame.width * 0.6, height: frame.height * 0.3)
        nameGame.position = CGPoint(x: frame.width * 0.60, y: frame.height * 0.73)
        addChild(nameGame)
        
        // ส่วนของการสร้างปุ่ม Start Game
        let startButton = SKSpriteNode(imageNamed: "StartButton.png")
        startButton.name = "startButton"
        startButton.size = CGSize(width: frame.width * 0.3, height: frame.height * 0.35)
        startButton.position = CGPoint(x: CGRectGetMidX(frame), y: frame.height * 0.30)
        addChild(startButton)
    }
    
    func soundBackground() {
        
        let path = NSBundle.mainBundle().pathForResource("SoundMain", ofType: "mp3")
        var pathURL = NSURL(fileURLWithPath: path!)
        soundBG = AVAudioPlayer(contentsOfURL: pathURL, error: nil)
        soundBG?.prepareToPlay()
        soundBG?.numberOfLoops = -1
        soundBG?.volume = 0.5
        soundBG?.play()
    }
    
    func soundTouch() {
        
        let path = NSBundle.mainBundle().pathForResource("break", ofType: "wav")
        var pathURL = NSURL(fileURLWithPath: path!)
        soundButton = AVAudioPlayer(contentsOfURL: pathURL, error: nil)
        soundButton.prepareToPlay()
        soundButton.numberOfLoops = 3
        soundButton.volume = 0.5
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            
            let location = (touch as UITouch).locationInNode(self)
            
            if let theName = self.nodeAtPoint(location).name {
                
                if theName == "startButton" {
                    
                    soundButton.play()
                    let skView = SKView(frame: frame)
                    let scene = GameScene(size: skView.bounds.size)
                    
                    view?.presentScene(scene, transition: SKTransition.flipHorizontalWithDuration(1.0))
                }
            }
        }
    }
    
    // Static Function ที่ใช้สร้างฉากการเล่นเกมส์
    class func scene(size:CGSize) -> MainScene {
        
        return MainScene(size: size)
    }
}