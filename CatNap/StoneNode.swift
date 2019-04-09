//
//  StoneNode.swift
//  CatNap
//
//  Created by xulingjiao on 2019/4/9.
//  Copyright © 2019 Sprite. All rights reserved.
//

import SpriteKit

class StoneNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    
    func didMoveToScene() {
        let levelScene = scene
        if parent == levelScene {
            levelScene!.addChild(StoneNode.makeCompoundNode(inScene: levelScene!))
        }
    }
    
    func interact() {
        isUserInteractionEnabled = false
        run(SKAction.sequence([SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false), SKAction.removeFromParent()]))
    }
    
    static func makeCompoundNode(inScene scene: SKScene) -> SKNode {
        let compound = StoneNode()
        compound.zPosition = -1
        for stone in scene.children.filter({ nd in nd is StoneNode}) {
            stone.removeFromParent()
            compound.addChild(stone)
        }
        let bodies = compound.children.map({ node in
            SKPhysicsBody(rectangleOf: node.frame.size, center: node.position)
        })
        compound.physicsBody = SKPhysicsBody(bodies: bodies)
        compound.physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Cat | PhysicsCategory.Block
        compound.physicsBody!.categoryBitMask = PhysicsCategory.Block
        compound.isUserInteractionEnabled = true
        compound.zPosition = 1
        return compound
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
}
