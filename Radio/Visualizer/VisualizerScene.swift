//
//  VisualizerScene.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//

// VisualizerScene.swift
import SpriteKit

class VisualizerScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Load particles or any setup specific to VisualizerScene
        let visualizerParticle = SKEmitterNode(fileNamed: "VisualizerScene")
        visualizerParticle?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(visualizerParticle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches or interaction specific to VisualizerScene if needed
    }
}

