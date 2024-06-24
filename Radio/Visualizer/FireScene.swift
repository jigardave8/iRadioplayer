//
//  FireScene.swift
//  Radio
//
//  Created by Jigar on 23/06/24.
//

// FireScene.swift
import SpriteKit

class FireScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Load particles or any setup specific to FireScene
        let fireParticle = SKEmitterNode(fileNamed: "FireScene")
        fireParticle?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(fireParticle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches or interaction specific to FireScene if needed
    }
}
