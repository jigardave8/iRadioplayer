import SwiftUI

struct MediaView: View {
    // MARK: - Properties
    @ObservedObject var libraryViewModel = LibraryViewModel.shared
    @ObservedObject var audioPlayerManager = AudioPlayerManager.shared
    
    // MARK: - State Variables
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var currentGradientIndex = 0
    @State private var useDedicatedGradient = false
    @State private var animationPhase = 0.0
    @State private var isSettingsViewPresented = false
    @State private var isMediaLibraryViewPresented = false
    @State private var isVisualizerViewPresented = false
    
    // MARK: - Constants
    private let buttonSize: CGFloat = 30
    private let largeButtonSize: CGFloat = 40
    private let spacing: CGFloat = 20
    private let cornerRadius: CGFloat = 15
    
    let gradients: [[Color]] = [
        [.blue, .purple],
        [.purple, .red],
        [.red, .orange],
        [.orange, .yellow],
        [.yellow, .green],
        [.green, .blue]
    ]
    
    // MARK: - Computed Properties
    private var isPlaying: Bool {
        audioPlayerManager.isPlaying
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    backgroundLayer
                    
                    VStack(spacing: spacing) {
                        nowPlayingSection
                        progressSection
                        controlsSection
                        volumeSection
                    }
                    .padding()
                    
                    if isSearching {
                        searchOverlay
                    }
                }
                .navigationBarItems(trailing: navigationButtons)
                .sheet(isPresented: $isSettingsViewPresented) {
                    SettingsView(audioPlayerManager: audioPlayerManager)
                }
                .sheet(isPresented: $isMediaLibraryViewPresented) {
                    MediaLibraryView()
                }
                .sheet(isPresented: $isVisualizerViewPresented) {
                    VisualizerView()
                }
                .onAppear(perform: setupOnAppear)
            }
        }
    }
    
    private var volumeSection: some View {
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.white)
                
                Slider(
                    value: Binding(
                        get: { Double(audioPlayerManager.volume) },
                        set: { audioPlayerManager.updateVolume(Float($0)) }
                    ),
                    in: 0...1
                )
                .accentColor(.white)
                
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
        }
    
    // MARK: - View Components
    private var backgroundLayer: some View {
        Group {
            if useDedicatedGradient {
                AnimatedGradientBackground(phase: animationPhase)
            } else {
                StaticGradientBackground(gradientIndex: currentGradientIndex)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var nowPlayingSection: some View {
        NowPlayingView(audioPlayerManager: audioPlayerManager)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.black.opacity(0.3))
                    .shadow(radius: 10)
            )
    }
    
    private var progressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text(timeString(time: audioPlayerManager.currentPlaybackTime))
                    .foregroundColor(.white)
                Spacer()
                Text("-\(timeString(time: audioPlayerManager.currentSongDuration - audioPlayerManager.currentPlaybackTime))")
                    .foregroundColor(.white)
            }
            .font(.caption)
            
            CustomSlider(value: Binding(
                get: { audioPlayerManager.currentPlaybackTime },
                set: { audioPlayerManager.seek(to: $0) }
            ), in: 0...audioPlayerManager.currentSongDuration)
        }
        .padding(.horizontal)
    }
    
    private var controlsSection: some View {
        HStack(spacing: spacing) {
            MediaControlButton(icon: "shuffle", color: .white, action: audioPlayerManager.shuffle)
            MediaControlButton(icon: "backward.fill", color: .white, action: audioPlayerManager.playPrevious)
            
            PlayPauseButton(isPlaying: isPlaying) {
                audioPlayerManager.togglePlayPause()
            }
            
            MediaControlButton(icon: "forward.fill", color: .white, action: audioPlayerManager.playNext)
            MediaControlButton(icon: "stop.fill", color: .red, action: audioPlayerManager.stop)
        }
        .padding(.vertical)
    }
    
    
    private var navigationButtons: some View {
        HStack(spacing: spacing) {
            NavigationButton(icon: "music.note.list", action: { isMediaLibraryViewPresented.toggle() })
            NavigationButton(icon: "waveform.path.ecg", action: { isVisualizerViewPresented.toggle() })
            NavigationButton(icon: "headphones.circle", action: { isSettingsViewPresented.toggle() })
        }
    }
    
    private var searchOverlay: some View {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                withAnimation {
                    isSearching = false
                    searchText = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil,
                                                 from: nil,
                                                 for: nil)
                }
            }
    }
    
    // MARK: - Helper Functions
    private func setupOnAppear() {
        libraryViewModel.fetchSongs()
        audioPlayerManager.setupAudioSession()
        startGradientAnimation()
    }
    
    private func startGradientAnimation() {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
            animationPhase += 360
        }
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Views
struct MediaControlButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

struct PlayPauseButton: View {
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
        }
    }
}

struct NavigationButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .imageScale(.large)
                .foregroundColor(.white)
        }
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    init(value: Binding<Double>, in range: ClosedRange<Double>) {
        self._value = value
        self.range = range
    }
    
    var body: some View {
        Slider(value: $value, in: range)
            .accentColor(.white)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)
            )
    }
}

