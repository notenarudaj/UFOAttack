//
//  GameViewController.swift
//  UFOAttack
//
//  Created by note on 4/29/2558 BE.
//  Copyright (c) 2558 Narudaj. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = self.view as SKView
        //let scene = GameScene(size: skView.bounds.size)
        let scene = MainScene(size: skView.bounds.size)
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = false
        scene.scaleMode = .Fill
        
        skView.presentScene(scene)
    }
}
