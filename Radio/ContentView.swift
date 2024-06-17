
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selectedTab: Tab = .radio
    
    enum Tab: String, CaseIterable {
        case radio = "Radio"
        case media = "Media"
        
        var icon: String {
            switch self {
            case .radio:
                return "radio"
            case .media:
                return "music.note"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            switch selectedTab {
            case .radio:
                RadioView()
            case .media:
                MediaView()
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation {
                            selectedTab = tab
                        }
                    }) {
                        VStack {
                            Image(systemName: tab.icon)
                                .font(.system(size: 24))
                            Text(tab.rawValue)
                                .font(.headline)
                        }
                        .padding()
                        .foregroundColor(tab == selectedTab ? Color.white : Color.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .background(tab == selectedTab ? Color.blue : Color.clear)
                }
            }
            .background(Color.black)
        }
        .padding(.bottom, 20) // Add padding to the bottom of the VStack
        .background(Color(red: 0.2, green: 0.2, blue: 0.2).edgesIgnoringSafeArea(.all))
        .onAppear {
            setupAudioSession()
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session:", error.localizedDescription)
        }
    }
}
