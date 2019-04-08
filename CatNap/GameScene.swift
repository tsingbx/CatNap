//
//  GameScene.swift
//  CatNap
//
//  Created by xulingjiao on 2019/4/3.
//  Copyright © 2019 Sprite. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol CustomNodeEvents {
    func didMoveToScene()
}

protocol InteractiveNode {
    func interact()
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Cat: UInt32 = 0b1 //1
    static let Block: UInt32 = 0b10 //2
    static let Bed: UInt32 = 0b100 //4
    static let Edge: UInt32 = 0b1000 //8
    static let Label: UInt32 = 0b10000 //16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bedNode: BedNode!
    var catNode: CatNode!
    var playable = true
    
    override func didMove(to view: SKView) {
        let maxAspectRadio : CGFloat = 16.0/9.0
        let maxAspectRadioHeight : CGFloat = size.width / maxAspectRadio
        let playableMargein: CGFloat = (size.height - maxAspectRadioHeight) / 2
        let playableRect = CGRect(x: 0, y: playableMargein, width: size.width, height: size.height - playableMargein * 2)
        physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        bedNode = (childNode(withName: "bed") as! BedNode)
        catNode = (childNode(withName: "//cat_body") as! CatNode)
        enumerateChildNodes(withName: "//*") { (node, _) in
            if let customNode = node as? CustomNodeEvents {
                customNode.didMoveToScene()
            }
        }
        SKTAudio.sharedInstance().playBackgroundMusic(filename: "backgroundMusic.mp3")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Label | PhysicsCategory.Edge {
            let messageNode = (childNode(withName: "message") as! MessageNode)
            messageNode.didBounce()
        }
        if !playable {
            return
        }
        if collision == PhysicsCategory.Cat | PhysicsCategory.Bed {
            win()
        }
        else if collision == PhysicsCategory.Cat | PhysicsCategory.Edge {
            lose()
        }
    }
    
    func inGameMessage(text: String) {
        let message = MessageNode(message: text)
        message.name = "message"
        message.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(message)
    }
    
    @objc func newGame() {
        let scene = GameScene(fileNamed: "GameScene")
        scene!.scaleMode = scaleMode
        view!.presentScene(scene)
    }
    
    func lose() {
        playable = false
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        run(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        inGameMessage(text: "Try again...")
        perform(#selector(newGame), with: nil, afterDelay: 5)
        catNode.wakeUp()
    }
    
    func win() {
        playable = false
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        inGameMessage(text: "Nice job!")
        //perform(#selector(newGame), with: nil, afterDelay: 3)
        catNode.curlAt(scenePoint: bedNode.position)
    }
    
}
