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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
//            createWaveformEffect(at: location)
            createWaterRippleEffect(at: location)
            createCircularGeometryEffect(at: location)
//            createECGEffect(at: location)
        }
    }
    
    func createWaveformEffect(at position: CGPoint) {
        let waveformNode = SKShapeNode()
        let path = UIBezierPath()
        
        for i in 0..<50 {
            let x = position.x + CGFloat(i) * 10
            let y = position.y + sin(CGFloat(i) * 0.5) * 20
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        waveformNode.path = path.cgPath
        waveformNode.strokeColor = .green
        waveformNode.lineWidth = 2
        addChild(waveformNode)
        
        let fadeOut = SKAction.fadeOut(withDuration: 2)
        let remove = SKAction.removeFromParent()
        waveformNode.run(SKAction.sequence([fadeOut, remove]))
    }
    
    func createWaterRippleEffect(at position: CGPoint) {
        let rippleNode = SKShapeNode(circleOfRadius: 0)
        rippleNode.position = position
        rippleNode.strokeColor = .blue
        rippleNode.lineWidth = 2
        addChild(rippleNode)
        
        let scaleUp = SKAction.scale(to: 100, duration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let remove = SKAction.removeFromParent()
        rippleNode.run(SKAction.sequence([SKAction.group([scaleUp, fadeOut]), remove]))
    }
    
    func createCircularGeometryEffect(at position: CGPoint) {
        let circleNode = SKShapeNode(circleOfRadius: 50)
        circleNode.position = position
        circleNode.strokeColor = .red
        circleNode.lineWidth = 4
        addChild(circleNode)
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2)
        let fadeOut = SKAction.fadeOut(withDuration: 2)
        let remove = SKAction.removeFromParent()
        circleNode.run(SKAction.sequence([SKAction.group([rotate, fadeOut]), remove]))
    }
    
    func createECGEffect(at position: CGPoint) {
        let ecgNode = SKShapeNode()
        let path = UIBezierPath()
        
        for i in 0..<100 {
            let x = position.x + CGFloat(i) * 5
            let y: CGFloat
            if i % 20 < 10 {
                y = position.y + 20
            } else {
                y = position.y - 20
            }
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        ecgNode.path = path.cgPath
        ecgNode.strokeColor = .yellow
        ecgNode.lineWidth = 2
        addChild(ecgNode)
        
        let fadeOut = SKAction.fadeOut(withDuration: 2)
        let remove = SKAction.removeFromParent()
        ecgNode.run(SKAction.sequence([fadeOut, remove]))
    }
}
