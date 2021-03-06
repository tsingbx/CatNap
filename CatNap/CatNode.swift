//
//  CatNode.swift
//  CatNap
//
//  Created by xulingjiao on 2019/4/8.
//  Copyright © 2019 Sprite. All rights reserved.
//

import SpriteKit

let kCatTappedNotification = "kCatTappedNotification"

class CatNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    
    private var isDoingTheDance = false
    
    func didMoveToScene() {
        isUserInteractionEnabled = true
        let catBodyTexture = SKTexture(imageNamed: "cat_body_outline_image")
        parent!.physicsBody = SKPhysicsBody(texture: catBodyTexture, size: catBodyTexture.size())
        parent!.physicsBody!.categoryBitMask = PhysicsCategory.Cat
        parent!.physicsBody!.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge | PhysicsCategory.Spring | PhysicsCategory.Seesaw
        parent!.physicsBody!.contactTestBitMask = PhysicsCategory.Bed | PhysicsCategory.Edge
    }
    
    func wakeUp() {
        for child in children {
            child.removeFromParent()
        }
        texture = nil
        color = SKColor.clear
        let catAwake = SKSpriteNode(fileNamed: "CatWakeUp")!.childNode(withName: "cat_awake")
        catAwake!.move(toParent: self)
        catAwake!.position = CGPoint(x: -30, y: 100)
        catAwake!.isPaused = true
        catAwake!.isPaused = false
    }
    
    func curlAt(scenePoint: CGPoint) {
        parent!.physicsBody = nil
        for child in children {
            child.removeFromParent()
        }
        texture = nil
        color = SKColor.clear
        let catCurl = SKSpriteNode(fileNamed: "CatCurl")!.childNode(withName: "cat_curl")!
        catCurl.move(toParent: self)
        catCurl.position = CGPoint(x: -30, y: 100)
        var localPoint = parent!.convert(scenePoint, from: scene!)
        localPoint.y += frame.size.height/3
        catCurl.isPaused = true
        catCurl.isPaused = false
        run(SKAction.group([SKAction.move(to: localPoint, duration: 0.66), SKAction.rotate(toAngle: 0, duration: 0.5)]))
    }
    
    func interact() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kCatTappedNotification)))
        if DiscoBallNode.isDiscoTime && !isDoingTheDance {
            isDoingTheDance = true
            let move = SKAction.sequence([SKAction.moveBy(x: 80, y: 0, duration: 0.5), SKAction.wait(forDuration: 0.5), SKAction.moveBy(x: -30, y: 0, duration: 0.5)])
            let dance = SKAction.repeat(move, count: 3)
            parent!.run(dance, completion: {
                self.isDoingTheDance = false
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
}
