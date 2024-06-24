//
//  RainScene.swift
//  Radio
//
//  Created by Jigar on 23/06/24.
//

// RainScene.swift
import SpriteKit

class RainScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Load particles or any setup specific to RainScene
        let rainParticle = SKEmitterNode(fileNamed: "RainScene")
        rainParticle?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(rainParticle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches or interaction specific to RainScene if needed
    }
}
