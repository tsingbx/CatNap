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
    static let Spring: UInt32 = 0b100000 //32
    static let Hook: UInt32 = 0b1000000 //64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bedNode: BedNode!
    var catNode: CatNode!
    var playable: Bool = true
    var currentLevel: Int = 0
    var hookNode: HookNode?
    
    class func level(levelNum: Int) -> GameScene? {
        let scene = GameScene(fileNamed: "Level\(levelNum)")!
        scene.currentLevel = levelNum
        scene.scaleMode = .aspectFill
        return scene
    }
    
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
        //let rotationConstraint = SKConstraint.zRotation(SKRange(lowerLimit: -π/4, upperLimit: π/4))
        //catNode.parent!.constraints = [rotationConstraint]
        hookNode = childNode(withName: "hookBase") as? HookNode
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Label | PhysicsCategory.Edge {
            let messageNode = (childNode(withName: "message") as! MessageNode)
            messageNode.didBounce()
        }
        if collision == PhysicsCategory.Cat | PhysicsCategory.Hook && hookNode?.isHooked == false {
            hookNode!.hookCat(catNode: catNode)
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
        view!.presentScene(GameScene.level(levelNum: currentLevel))
    }
    
    func lose() {
        if currentLevel > 1 {
            currentLevel -= 1
        }
        playable = false
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        run(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        inGameMessage(text: "Try again...")
        perform(#selector(newGame), with: nil, afterDelay: 5)
        catNode.wakeUp()
    }
    
    func win() {
        if currentLevel < 3 {
            currentLevel += 1
        }
        playable = false
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        inGameMessage(text: "Nice job!")
        perform(#selector(newGame), with: nil, afterDelay: 3)
        catNode.curlAt(scenePoint: bedNode.position)
    }
    
    override func didSimulatePhysics() {
        if playable && hookNode?.isHooked != true {
            let cons = SKConstraint.zRotation(SKRange(lowerLimit: 0, upperLimit: 24))
            catNode.constraints = [cons]
        }
    }
    
    override func didFinishUpdate() {
        if playable && hookNode?.isHooked == false {
            if abs(catNode.parent!.zRotation) > CGFloat(45).degreesToRadians() {
                lose()
            }
        }
    }
    
}
