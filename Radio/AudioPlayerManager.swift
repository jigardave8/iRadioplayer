// AudioPlayerManager.swift
import Foundation
import AVFoundation
import MediaPlayer
import Combine
import SwiftUI



// Add this extension for Float clamping
extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
// MARK: - Equalizer Setting Enum
enum EqualizerSetting: String, CaseIterable {
    case normal = "Normal"
    case rock = "Rock"
    case pop = "Pop"
    case jazz = "Jazz"
    case bass = "Bass"
    case treble = "Treble"
    case bassAndTreble = "Bass & Treble"
    case classical = "Classical"
    case hipHop = "Hip-Hop"
    case reset = "Reset"
}

// MARK: - Audio Player Manager
class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()
    @Published var volume: Float = 0.5 {
           didSet {
               audioPlayer?.volume = volume
           }
       }

    @Published var isPlaying: Bool = false
    @Published var audioLevels: Float = 0.0
    @Published var showSettings: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var currentSong: MPMediaItem?
    @Published var currentEqualizerSetting: EqualizerSetting = .normal {
        didSet {
            applyEqualizerSetting()
        }
    }

    private var audioPlayer: AVAudioPlayer?
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var audioEngine: AVAudioEngine?
    private var eqNodes: [AVAudioUnitEQ] = []

    let currentTimePublisher = PassthroughSubject<TimeInterval, Never>()

    override init() {
        super.init()
        setupAudioSession()
        setupAudioEngine()
    }
    
    // Add volume control method
      func updateVolume(_ newVolume: Float) {
          volume = newVolume.clamped(to: 0...1)
          audioPlayer?.volume = volume
      }

    public func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session:", error.localizedDescription)
        }
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        eqNodes = EqualizerSetting.allCases.map { _ in
            let eq = AVAudioUnitEQ(numberOfBands: 10)
            audioEngine?.attach(eq)
            return eq
        }

        if let audioEngine = audioEngine {
            for i in 0..<eqNodes.count {
                if i < eqNodes.count - 1 {
                    audioEngine.connect(eqNodes[i], to: eqNodes[i + 1], format: nil)
                } else {
                    audioEngine.connect(eqNodes[i], to: audioEngine.mainMixerNode, format: nil)
                }
            }
        }
        applyEqualizerSetting()
    }

    // MARK: - Playback Controls
    func play(song: MPMediaItem) {
        guard let url = song.assetURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            currentSong = song
            startUpdatingCurrentTime()
        } catch {
            print("Failed to play audio:", error.localizedDescription)
        }
    }

    private func startUpdatingCurrentTime() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }
        timer?.fire()
    }

    private func updateCurrentTime() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
        currentTimePublisher.send(currentTime)
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    func togglePlayPause() {
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
                isPlaying = false
            } else {
                player.play()
                isPlaying = true
                startUpdatingCurrentTime()
            }
        }
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Audio Player Controls
    func playNext() {
        guard !LibraryViewModel.shared.songs.isEmpty else { return }
        currentIndex = (currentIndex + 1) % LibraryViewModel.shared.songs.count
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    func playPrevious() {
        guard !LibraryViewModel.shared.songs.isEmpty else { return }
        currentIndex = (currentIndex - 1 + LibraryViewModel.shared.songs.count) % LibraryViewModel.shared.songs.count
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    func shuffle() {
        LibraryViewModel.shared.songs.shuffle()
        currentIndex = 0
        if !LibraryViewModel.shared.songs.isEmpty {
            play(song: LibraryViewModel.shared.songs[currentIndex])
        }
    }

    // MARK: - Equalizer
    private func applyEqualizerSetting() {
        guard let audioEngine = audioEngine else { return }

        // Reset all bands
        for eq in eqNodes {
            for band in eq.bands {
                band.filterType = .parametric
                band.bypass = true
            }
        }

        // Apply new settings
        let gains: [Float]
        switch currentEqualizerSetting {
        case .normal:
            gains = Array(repeating: 0.0, count: 5)
        case .rock:
            gains = [3.0, 2.5, 2.0, 1.5, 1.0]
        case .pop:
            gains = [2.0, 2.0, 2.0, 1.0, 1.0]
        case .jazz:
            gains = [2.5, 2.0, 1.5, 1.0, 1.0]
        case .bass:
            gains = [4.0, 3.5, 3.0, 2.5, 2.0]
        case .treble:
            gains = [1.5, 1.0, 0.5, 0.0, 0.0]
        case .bassAndTreble:
            gains = [3.5, 3.0, 2.5, 2.0, 1.5]
        case .classical:
            gains = [2.0, 1.5, 1.0, 0.5, 0.5]
        case .hipHop:
            gains = [3.0, 2.5, 2.0, 1.5, 1.5]
        case .reset:
            gains = Array(repeating: 0.0, count: 5)
        }

        applyBandsSettings(gains)
        
        audioEngine.mainMixerNode.outputVolume = audioLevels
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine:", error.localizedDescription)
        }
    }

    private func applyBandsSettings(_ values: [Float]) {
        for (index, value) in values.enumerated() {
            if index < eqNodes.count {
                let eq = eqNodes[index]
                for band in eq.bands {
                    band.gain = value
                    band.bypass = false
                }
            }
        }
    }

    // MARK: - Time Properties
    var currentPlaybackTime: Double {
        return audioPlayer?.currentTime ?? 0
    }

    var currentSongDuration: Double {
        return audioPlayer?.duration ?? 0
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playNext()
    }
}



// MARK: - Views
struct AudioPlayerView: View {
    @StateObject private var playerManager = AudioPlayerManager.shared
    @State private var dragOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var isShowingEqualizer = false
    
    let gradientColors = [
        Color(hex: "1A2980"),
        Color(hex: "26D0CE")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: gradientColors),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                albumArtView
                songInfoView
                progressBarView
                controlsView
                equalizerButton
            }
            .padding()
        }
        .sheet(isPresented: $isShowingEqualizer) {
            EqualizerView()
        }
    }
    
    private var albumArtView: some View {
        ZStack {
            if let artwork = playerManager.currentSong?.artwork {
                Image(uiImage: artwork.image(at: CGSize(width: 300, height: 300)) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                    .scaleEffect(scale)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: scale)
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                withAnimation {
                                    scale = 0.9
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        scale = 1.0
                                    }
                                }
                            }
                    )
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                    )
            }
        }
        .rotation3DEffect(
            .degrees(playerManager.isPlaying ? 2 : 0),
            axis: (x: 1.0, y: 1.0, z: 0.0)
        )
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                  value: playerManager.isPlaying)
    }
    
    private var songInfoView: some View {
        VStack(spacing: 8) {
            Text(playerManager.currentSong?.title ?? "No Song Playing")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(playerManager.currentSong?.artist ?? "Unknown Artist")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(height: 60)
    }
    
    private var progressBarView: some View {
            VStack(spacing: 8) {
                Slider(value: Binding(
                    get: { playerManager.currentPlaybackTime },
                    set: { playerManager.seek(to: $0) }
                ), in: 0...playerManager.currentSongDuration)
                .accentColor(.white)
                
                HStack {
                    Text(timeString(from: playerManager.currentPlaybackTime))
                    Spacer()
                    Text(timeString(from: playerManager.currentSongDuration))
                }
                .font(.caption)
                .foregroundColor(.white)
            }
        }
        
        private var controlsView: some View {
            HStack(spacing: 40) {
                Button(action: {
                    withAnimation {
                        playerManager.playPrevious()
                    }
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    withAnimation {
                        playerManager.togglePlayPause()
                    }
                }) {
                    Image(systemName: playerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    withAnimation {
                        playerManager.playNext()
                    }
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 35))
                        .foregroundColor(.white)
                }
            }
        }
        
        private var equalizerButton: some View {
            Button(action: { isShowingEqualizer.toggle() }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Equalizer")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                .foregroundColor(.white)
            }
        }
        
        // MARK: - Helper Functions
        
        private func timeString(from timeInterval: TimeInterval) -> String {
            let minutes = Int(timeInterval / 60)
            let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // MARK: - Equalizer View
    struct EqualizerView: View {
        @StateObject private var playerManager = AudioPlayerManager.shared
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                List {
                    ForEach(EqualizerSetting.allCases, id: \.self) { setting in
                        Button(action: {
                            playerManager.currentEqualizerSetting = setting
                        }) {
                            HStack {
                                Text(setting.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if setting == playerManager.currentEqualizerSetting {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Equalizer")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }

    // MARK: - Supporting Extensions
    extension Color {
        init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3:
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6:
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8:
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
    }

    // MARK: - Preview Provider
    struct AudioPlayerView_Previews: PreviewProvider {
        static var previews: some View {
            AudioPlayerView()
        }
    }
