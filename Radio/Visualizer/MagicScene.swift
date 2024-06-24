//
//  MagicScene.swift
//  Radio
//
//  Created by Jigar on 23/06/24.
//

// MagicScene.swift
import SpriteKit

class MagicScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Load particles or any setup specific to MagicScene
        let magicParticle = SKEmitterNode(fileNamed: "MagicScene")
        magicParticle?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(magicParticle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches or interaction specific to MagicScene if needed
    }
}
