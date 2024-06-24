//
//  SmokeScene.swift
//  Radio
//
//  Created by Jigar on 23/06/24.
//

// SmokeScene.swift
import SpriteKit

class SmokeScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Load particles or any setup specific to SmokeScene
        let smokeParticle = SKEmitterNode(fileNamed: "SmokeScene")
        smokeParticle?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(smokeParticle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches or interaction specific to SmokeScene if needed
    }
}
