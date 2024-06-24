//
//  SnowScene.swift
//  Radio
//
//  Created by Jigar on 23/06/24.
//

// SnowScene.swift
import SpriteKit

class SnowScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Load particles or any setup specific to SnowScene
        let snowParticle = SKEmitterNode(fileNamed: "SnowScene")
        snowParticle?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(snowParticle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches or interaction specific to SnowScene if needed
    }
}
