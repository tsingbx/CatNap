//
//  SeesawNode.swift
//  CatNap
//
//  Created by xulingjiao on 2019/4/9.
//  Copyright © 2019 Sprite. All rights reserved.
//

import SpriteKit

class SeesawNode: SKSpriteNode, CustomNodeEvents {
    func didMoveToScene() {
        physicsBody!.categoryBitMask = PhysicsCategory.Seesaw
        physicsBody!.collisionBitMask = PhysicsCategory.Cat | PhysicsCategory.Block
        let cons = SKConstraint.zRotation(SKRange(lowerLimit: -π/6, upperLimit: π/6))
        constraints = [cons]
        let seesawBase = scene?.childNode(withName: "seesawBase")
        let anchorPoint = CGPoint(x: position.x, y: position.y+size.height/2)
        let pinJoint = SKPhysicsJointPin.joint(withBodyA: seesawBase!.physicsBody!, bodyB: physicsBody!, anchor: anchorPoint)
        scene!.physicsWorld.add(pinJoint)
    }
}
