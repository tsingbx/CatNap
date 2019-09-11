//
//  DiscoBallNode.swift
//  CatNap
//
//  Created by xulingjiao on 2019/4/10.
//  Copyright © 2019 Sprite. All rights reserved.
//

import SpriteKit
import AVFoundation

class DiscoBallNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    
    private var player: AVPlayer!
    private var video: SKVideoNode!
    private var isReadyToPlay: Bool = false
    private var isDiscoTime: Bool = false {
        didSet {
            video.isHidden = !isDiscoTime
            if isDiscoTime {
                play()
                run(spinAction)
            }
            else {
                pause()
                removeAllActions()
            }
            SKTAudio.sharedInstance().playBackgroundMusic(filename: isDiscoTime ? "disco-sound.m4a" : "backgroundMusic.mp3")
            if isDiscoTime {
                video.run(SKAction.afterDelay(5, runBlock: {
                    self.isDiscoTime = false
                }))
            }
            
            DiscoBallNode.isDiscoTime = isDiscoTime
        }
    }
    
    static private(set) var isDiscoTime = false
    
    private let spinAction = SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "discoball1"), SKTexture(imageNamed: "discoball2"), SKTexture(imageNamed: "discoball3")], timePerFrame: 0.2))
    
    func didMoveToScene() {
        isUserInteractionEnabled = true
        let fileUrl = Bundle.main.url(forResource: "discolights-loop", withExtension: "mov")
        player = AVPlayer(url: fileUrl!)
        player.currentItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        video = SKVideoNode(avPlayer: player)
        video.size = scene!.size
        video.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY)
        video.zPosition = -1
        video.alpha = 0.75
        video.isHidden = true
        isReadyToPlay = false
        scene!.addChild(video)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReachEndOfVideo), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }
    
    func interact() {
        self.isDiscoTime = !self.isDiscoTime
    }
    
    @objc func didReachEndOfVideo() {
        print("rewind!")
        player.currentItem!.seek(to: CMTime.zero)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let playerItem = object as! AVPlayerItem;
            if playerItem.status == AVPlayerItem.Status.readyToPlay {
                player.currentItem!.removeObserver(self, forKeyPath: "status", context: nil)
                isReadyToPlay = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func play() {
        if isReadyToPlay {
            player.play()
        }
    }
    
    func pause(){
        if isReadyToPlay {
            player.pause()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
