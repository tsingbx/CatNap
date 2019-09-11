//
//  PictureNode.swift
//  CatNap
//
//  Created by xulingjiao on 2019/4/10.
//  Copyright © 2019 Sprite. All rights reserved.
//

import SpriteKit

class PictureNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    
    func didMoveToScene() {
        isUserInteractionEnabled = true
        let pictureNode = SKSpriteNode(imageNamed: "picture")
        let maskNode = SKSpriteNode(imageNamed: "picture-frame-mask")
        let cropNode = SKCropNode()
        cropNode.addChild(pictureNode)
        cropNode.maskNode = maskNode
        addChild(cropNode)
    }
    
    func interact() {
        isUserInteractionEnabled = false
        physicsBody!.isDynamic = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        interact()
    }
}
