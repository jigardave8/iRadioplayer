//
//  SparkScene.swift
//  Radio
//
//  Created by Jigar on 23/06/24.
//

// SparkScene.swift
import SpriteKit

class SparkScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Load particles or any setup specific to SparkScene
        let sparkParticle = SKEmitterNode(fileNamed: "SparkScene")
        sparkParticle?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(sparkParticle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches or interaction specific to SparkScene if needed
    }
}
