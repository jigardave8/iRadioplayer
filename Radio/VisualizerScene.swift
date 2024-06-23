//
//  VisualizerScene.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//

import SpriteKit

class VisualizerScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Particle settings
        let particle = SKEmitterNode(fileNamed: "VisualizerScene")!
        particle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(particle)
    }
}
