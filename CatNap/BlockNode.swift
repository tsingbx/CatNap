//
//  BlockNode.swift
//  CatNap
//
//  Created by xulingjiao on 2019/4/8.
//  Copyright © 2019 Sprite. All rights reserved.
//

import SpriteKit

class BlockNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    func didMoveToScene() {
        isUserInteractionEnabled = true
        physicsBody!.collisionBitMask = PhysicsCategory.Seesaw | PhysicsCategory.Edge | PhysicsCategory.Block
    }
    
    func interact() {
        isUserInteractionEnabled = false
        run(SKAction.sequence([SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false), SKAction.scale(to: 0.8, duration: 0.1), SKAction.removeFromParent()]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("destroy block")
        interact()
    }
}
