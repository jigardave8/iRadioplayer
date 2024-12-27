import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selectedTab: Tab = .radio
    @Environment(\.colorScheme) var colorScheme
    
    enum Tab: String, CaseIterable {
        case radio = "Radio"
        case media = "Media"
        
        var icon: String {
            switch self {
            case .radio:
                return "radio.fill"
            case .media:
                return "music.note.list"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RadioView()
                .tag(Tab.radio)
                .tabItem {
                    Label(Tab.radio.rawValue, systemImage: Tab.radio.icon)
                }
            
            MediaView()
                .tag(Tab.media)
                .tabItem {
                    Label(Tab.media.rawValue, systemImage: Tab.media.icon)
                }
        }
        .accentColor(.blue)
        .preferredColorScheme(.dark) // Force dark mode for better media player experience
        .onAppear {
            setupAppearance()
            setupAudioSession()
        }
    }
    
    private func setupAppearance() {
        // Custom tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color(red: 0.1, green: 0.1, blue: 0.1))
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed:", error)
        }
    }
}
