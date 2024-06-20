////
////  CombinedView.swift
////  Radio
////
////  Created by Jigar on 03/10/23.
////

import SwiftUI
import AVFoundation
import MediaPlayer
import Combine

// MARK: - LibraryViewModel

class LibraryViewModel: ObservableObject {
    static let shared = LibraryViewModel()

    @Published var songs: [MPMediaItem] = []
    @Published var selectedSong: MPMediaItem?
    

    func fetchSongs() {
        let query = MPMediaQuery.songs()
        if let items = query.items {
            songs = items
        }
    }
    func filteredSongs(searchText: String) -> [MPMediaItem] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { song in
                let searchLowercased = searchText.lowercased()
                return song.title?.lowercased().contains(searchLowercased) == true ||
                song.artist?.lowercased().contains(searchLowercased) == true ||
                song.albumTitle?.lowercased().contains(searchLowercased) == true
            }
        }
    }
}

// MARK: - AudioPlayerManager

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()

    @Published var isPlaying: Bool = false
    @Published var audioLevels: Float = 0.0
    @Published var showSettings: Bool = false
    @Published var currentTime: TimeInterval = 0
    var audioPlayer: AVAudioPlayer?
    var currentIndex: Int = 0

    private var timer: Timer?
    let currentTimePublisher = PassthroughSubject<TimeInterval, Never>()

    // Equalizer settings
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

    @Published var currentEqualizerSetting: EqualizerSetting = .normal {
        didSet {
            applyEqualizerSetting()
        }
    }

    private var audioEngine: AVAudioEngine?
    private var eqNodes: [AVAudioUnitEQ] = []

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session:", error.localizedDescription)
        }
    }

    func play(song: MPMediaItem) {
        guard let url = song.assetURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            startUpdatingCurrentTime()
        } catch {
            print("Failed to play audio:", error.localizedDescription)
        }
    }

    func startUpdatingCurrentTime() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateCurrentTime()
        }
        timer?.fire()
    }

    func updateCurrentTime() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
        currentTimePublisher.send(currentTime)
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    func playNext() {
        currentIndex = (currentIndex + 1) % LibraryViewModel.shared.songs.count
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    func playPrevious() {
        currentIndex = (currentIndex - 1 + LibraryViewModel.shared.songs.count) % LibraryViewModel.shared.songs.count
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    func togglePlayPause() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
            startUpdatingCurrentTime()
        }
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    func shuffle() {
        LibraryViewModel.shared.songs.shuffle()
        currentIndex = 0
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    private func applyEqualizerSetting() {
        // Apply equalizer settings using AVAudioEngine and AVAudioUnitEQ
        // This is a placeholder for actual equalizer settings implementation
    }
}

extension AudioPlayerManager {
    var currentSong: MPMediaItem? {
        return LibraryViewModel.shared.songs.indices.contains(currentIndex) ? LibraryViewModel.shared.songs[currentIndex] : nil
    }

    var currentPlaybackTime: Double {
        return audioPlayer?.currentTime ?? 0
    }

    var currentSongDuration: Double {
        return audioPlayer?.duration ?? 0
    }
}

// MARK: - MediaView

struct MediaView: View {
    @ObservedObject var libraryViewModel = LibraryViewModel.shared
    @ObservedObject var audioPlayerManager = AudioPlayerManager.shared

    @State private var isSidebarExpanded = false
    @State private var searchText = ""
    @State private var isSearching = false // Track if the user is actively searching

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack { // Use ZStack to handle taps outside the search bar
                    HStack(spacing: 0) {
                        // Side Panel (Collapsible)
                        VStack {
                            Text("Media Library")
                                .font(.headline)
                                .padding()

                            // Search Bar
                            SearchBar(text: $searchText, isSearching: $isSearching)
                                .padding(.horizontal)
                                .onTapGesture {
                                    isSearching = true // Tap on search bar starts searching
                                }

                            List {
                                ForEach(libraryViewModel.filteredSongs(searchText: searchText), id: \.persistentID) { song in
                                    Button(action: {
                                        libraryViewModel.selectedSong = song
                                        audioPlayerManager.play(song: song)
                                    }) {
                                        HStack {
                                            Text(song.title ?? "Unknown Title")
                                                .foregroundColor(song == libraryViewModel.selectedSong ? .blue : .black)
                                                .padding(8)
                                                .background(song == libraryViewModel.selectedSong && audioPlayerManager.isPlaying ? Color.yellow : Color.white)
                                                .cornerRadius(8)
                                            Spacer()
                                            if song == libraryViewModel.selectedSong && audioPlayerManager.isPlaying {
                                                Image(systemName: "speaker.wave.2.fill")
                                                    .foregroundColor(.green)
                                                    .padding(8)
                                                    .background(Color.gray)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                libraryViewModel.fetchSongs()
                            }
                        }
                        .frame(width: isSidebarExpanded ? geometry.size.width * 0.6 : 0)
                        .background(Color.gray.opacity(0.1))
                        .animation(.easeInOut)

                        // Main Content Area
                        VStack {
                            // Now Playing View
                            NowPlayingView(audioPlayerManager: audioPlayerManager)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.6)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                )
                                .padding()

                            // Music Player Controls
                            HStack(spacing: 20) {
                                Spacer()
                                controlButton(iconName: "shuffle", action: audioPlayerManager.shuffle, color: .black)
                                controlButton(iconName: "backward.fill", action: audioPlayerManager.playPrevious, color: .gray)
                                controlButton(iconName: audioPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill", action: audioPlayerManager.togglePlayPause, color: .black, size: 30)
                                controlButton(iconName: "forward.fill", action: audioPlayerManager.playNext, color: .gray)
                                controlButton(iconName: "stop.fill", action: audioPlayerManager.stop, color: .red)
                                Spacer()
                            }
                            .padding()
                        }
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom)
                                .edgesIgnoringSafeArea(.all)
                        )
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    }

                    // Invisible view to handle taps outside the search bar
                    if isSearching {
                        Color.clear
                            .onTapGesture {
                                // Dismiss keyboard when tapping outside the search bar
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                isSearching = false
                            }
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                .navigationBarItems(leading:
                    Button(action: {
                        withAnimation {
                            self.isSidebarExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isSidebarExpanded ? "chevron.left" : "sidebar.left")
                            .padding()
                            .foregroundColor(.red)
                    },
                trailing:
                    HStack(spacing: 20) {
                        NavigationLink(destination: SettingsView(audioPlayerManager: audioPlayerManager)) {
                            Image(systemName: "gear")
                                .padding()
                                .foregroundColor(.black)
                        }
                        Button(action: {
                            // Implement custom action for the star button
                        }) {
                            Image(systemName: "star.fill")
                                .padding()
                                .foregroundColor(.yellow)
                        }
                    }
                )
                .onAppear {
                    audioPlayerManager.setupAudioSession()
                }
                .sheet(isPresented: $audioPlayerManager.showSettings) {
                    SettingsView(audioPlayerManager: audioPlayerManager)
                }
            }
        }
    }

    @ViewBuilder
    private func controlButton(iconName: String, action: @escaping () -> Void, color: Color, size: CGFloat = 20) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: size, height: size)
                .padding(12)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(size)
                .shadow(radius: 5)
        }
    }
}

// Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text, onCommit: {
                // Handle search on commit if needed
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .overlay(
                HStack {
                    Spacer()
                    if !text.isEmpty {
                        Button(action: {
                            text = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 10)
                        }
                    }
                }
            )
        }
        .padding(.horizontal)
    }
}


// MARK: - NowPlayingView

struct NowPlayingView: View {
    @ObservedObject var audioPlayerManager: AudioPlayerManager
    @State private var currentTime: TimeInterval = 0
    @State private var isSeeking = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                if let currentSong = getCurrentSong() {
                    // Album Art
                    AlbumArtView(albumArt: currentSong.artwork?.image(at: CGSize(width: 200, height: 200)))
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)

                    // Song Information
                    VStack(spacing: 10) {
                        MarqueeText(text: currentSong.title ?? "Unknown Title", rate: 0.04)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        MarqueeText(text: currentSong.artist ?? "Unknown Artist", rate: 0.04)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        MarqueeText(text: currentSong.albumTitle ?? "Unknown Album", rate: 0.04)
                            .font(.footnote)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Current Time and Duration
                    HStack {
                        Text("\(formattedTime(time: currentTime))")
                            .foregroundColor(.black)
                        Spacer()
                        Text("\(formattedTime(time: audioPlayerManager.currentSongDuration))")
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)

                    // Playback Slider
                    Slider(value: Binding(
                        get: { currentTime },
                        set: { newTime in
                            audioPlayerManager.seek(to: newTime)
                            currentTime = newTime
                        }
                    ), in: 0...(audioPlayerManager.currentSongDuration ?? 1))
                    .accentColor(.green)
                    .padding(.horizontal)
                    .onReceive(audioPlayerManager.currentTimePublisher) { time in
                        if !isSeeking {
                            currentTime = time
                        }
                    }
                } else {
                    // Placeholder when no song is selected
                    Text("No song selected")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        )
                        .padding()
                }
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                audioPlayerManager.updateCurrentTime()
            }
        }
    }

    private func getCurrentSong() -> MPMediaItem? {
        guard audioPlayerManager.currentIndex < LibraryViewModel.shared.songs.count else {
            return nil
        }
        return LibraryViewModel.shared.songs[audioPlayerManager.currentIndex]
    }

    private func formattedTime(time: Double) -> String {
        let interval = Int(time)
        let minutes = interval / 60
        let seconds = interval % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - AlbumArtView

struct AlbumArtView: View {
    var albumArt: UIImage?

    var body: some View {
        ZStack {
            if let albumArt = albumArt {
                Image(uiImage: albumArt)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
}

// MARK: - MarqueeText

struct MarqueeText: View {
    let text: String
    let rate: Double // Rate of scrolling

    var body: some View {
        GeometryReader { geometry in
            Text(text)
                .padding(.horizontal)
                .lineLimit(1) // Ensure only one line is shown
                .minimumScaleFactor(0.5) // Adjust minimum scale factor if needed
                .foregroundColor(.white)
                .modifier(MarqueeEffect(rate: rate, totalWidth: geometry.size.width))
        }
        .frame(height: 20) // Adjust height based on your design
    }
}

// MARK: - MarqueeEffect

struct MarqueeEffect: GeometryEffect {
    var rate: Double
    var totalWidth: CGFloat

    var animatableData: Double {
        get { rate }
        set { rate = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = CGFloat(rate) * totalWidth
        let transform = CGAffineTransform(translationX: -offset, y: 0)
        return ProjectionTransform(transform)
    }
}
