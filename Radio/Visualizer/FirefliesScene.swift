//
//  FirefliesScene.swift
//  Radio
//
//  Created by Jigar on 23/06/24.
//

// FirefliesScene.swift
import SpriteKit

class FirefliesScene: SKScene {
    override func didMove(to view: SKView) {
        // Setup scene properties
        backgroundColor = .clear
        
        // Load particles or any setup specific to FirefliesScene
        let firefliesParticle = SKEmitterNode(fileNamed: "FirefliesScene")
        firefliesParticle?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(firefliesParticle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle touches or interaction specific to FirefliesScene if needed
    }
}
