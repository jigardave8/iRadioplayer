//
//  VisualizerView.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//
import SwiftUI
import SpriteKit

struct VisualizerView: View {
    var scene: SKScene
    
    var body: some View {
        SpriteView(scene: scene)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .background(Color.black) // Customize background color
    }
}
