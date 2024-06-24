import SwiftUI
import SpriteKit

struct VisualizerView: View {
    @State private var currentSceneIndex = 0
    private let sceneTypes: [SKScene.Type] = [
        VisualizerScene.self,
        SparkScene.self,
        SnowScene.self,
        SmokeScene.self,
        RainScene.self,
        MagicScene.self,
        FirefliesScene.self,
        FireScene.self
    ]
    
    var body: some View {
        ZStack {
            if currentSceneIndex == 0 {
                SpriteView(scene: VisualizerScene(size: UIScreen.main.bounds.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .onTapGesture {
                        toggleScene()
                    }
            } else if currentSceneIndex == 1 {
                SpriteView(scene: SparkScene(size: UIScreen.main.bounds.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .onTapGesture {
                        toggleScene()
                    }
            } else if currentSceneIndex == 2 {
                SpriteView(scene: SnowScene(size: UIScreen.main.bounds.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .onTapGesture {
                        toggleScene()
                    }
            } else if currentSceneIndex == 3 {
                SpriteView(scene: SmokeScene(size: UIScreen.main.bounds.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .onTapGesture {
                        toggleScene()
                    }
            } else if currentSceneIndex == 4 {
                SpriteView(scene: RainScene(size: UIScreen.main.bounds.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .onTapGesture {
                        toggleScene()
                    }
            } else if currentSceneIndex == 5 {
                SpriteView(scene: MagicScene(size: UIScreen.main.bounds.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .onTapGesture {
                        toggleScene()
                    }
            } else if currentSceneIndex == 6 {
                SpriteView(scene: FirefliesScene(size: UIScreen.main.bounds.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .onTapGesture {
                        toggleScene()
                    }
            } else if currentSceneIndex == 7 {
                SpriteView(scene: FireScene(size: UIScreen.main.bounds.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
                    .onTapGesture {
                        toggleScene()
                    }
            }
        }
    }
    
    private func toggleScene() {
        currentSceneIndex = (currentSceneIndex + 1) % sceneTypes.count
    }
}
