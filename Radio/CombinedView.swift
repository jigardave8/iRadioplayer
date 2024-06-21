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
    @Published var currentSong: MPMediaItem?

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
            currentSong = song // Update the current song
            LibraryViewModel.shared.selectedSong = song // Update the selected song in the view model
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
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(2)
                                

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
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                )
                                .padding()

                            // Music Player Controls
                            HStack(spacing: 20) {
                                Spacer()
                                controlButton(iconName: "shuffle", action: audioPlayerManager.shuffle, color: .black)
                                controlButton(iconName: "backward.fill", action: audioPlayerManager.playPrevious, color: .gray)
                                controlButton(iconName: audioPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill", action: audioPlayerManager.togglePlayPause, color: .black, size: 40)
                                controlButton(iconName: "forward.fill", action: audioPlayerManager.playNext, color: .gray)
                                controlButton(iconName: "stop.fill", action: audioPlayerManager.stop, color: .red)
                                Spacer()
                            }
                            .padding()
                        }
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .edgesIgnoringSafeArea(.all)
                        )
                    }

                    // Dismiss the search view by tapping outside the search bar
                    if isSearching {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isSearching = false
                                searchText = "" // Clear search text when dismissed
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // Dismiss keyboard
                            }
                    }
                }
            }
//            .navigationBarTitle("Music Player", displayMode: .automatic)
            .navigationBarItems(leading: Button(action: {
                withAnimation {
                    isSidebarExpanded.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .imageScale(.large)
            })
            .onAppear {
                libraryViewModel.fetchSongs()
                audioPlayerManager.setupAudioSession()
            }
        }
    }

    private func controlButton(iconName: String, action: @escaping () -> Void, color: Color, size: CGFloat = 30) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
    }
}

// MARK: - NowPlayingView
struct NowPlayingView: View {
    @ObservedObject var audioPlayerManager: AudioPlayerManager
    @State private var isFullScreen = false // State to manage full-screen mode

    var body: some View {
        VStack {
            if let song = audioPlayerManager.currentSong {
                Text(song.title ?? "Unknown Title")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                Text(song.artist ?? "Unknown Artist")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
                

                ZStack {
                    if let artwork = song.artwork {
                        Image(uiImage: artwork.image(at: CGSize(width: 250, height: 250)) ?? UIImage(systemName: "music.note")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .padding(.bottom, 12)
                            .onTapGesture {
                                isFullScreen.toggle()
                            }
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .padding(.bottom, 12)
                            .cornerRadius(10)
                    }

                    // Full-screen overlay
                    if isFullScreen {
                        FullScreenView(song: song)
                            .onTapGesture {
                                isFullScreen.toggle()
                            }
                    }
                }

                HStack {
                    Text(timeString(time: audioPlayerManager.currentPlaybackTime))
                        .foregroundColor(.white)
                    Slider(value: Binding(get: {
                        self.audioPlayerManager.currentPlaybackTime
                    }, set: { (newTime) in
                        self.audioPlayerManager.seek(to: newTime)
                    }), in: 0...self.audioPlayerManager.currentSongDuration)
                    .accentColor(.green)
                    Text("-\(timeString(time: audioPlayerManager.currentSongDuration - audioPlayerManager.currentPlaybackTime))")
                        .foregroundColor(.white)
                }
                .padding(.vertical, 5)

            } else {
                Text("No song is currently playing.")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.vertical, 2)
            }
        }
        .sheet(isPresented: $isFullScreen, content: {
            if let song = audioPlayerManager.currentSong {
                FullScreenView(song: song)
            }
        })
        .padding(.horizontal, 24)
        .padding(.vertical, 2)
    }

    // Helper function to format time duration
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Full screen view to display song details
struct FullScreenView: View {
    var song: MPMediaItem

    var body: some View {
        VStack {
            Text(song.title ?? "Unknown Title")
                .font(.title)
                .foregroundColor(.white)
                .padding()

            if let artwork = song.artwork {
                Image(uiImage: artwork.image(at: CGSize(width: 300, height: 300)) ?? UIImage(systemName: "music.note")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding()
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding()
            }

            Text("Artist: \(song.artist ?? "Unknown Artist")")
                .foregroundColor(.white)
                .padding(.bottom, 10)

            Text("Album: \(song.albumTitle ?? "Unknown Album")")
                .foregroundColor(.white)
                .padding(.bottom, 10)

            Text("Duration: \(timeString(time: song.playbackDuration))")
                .foregroundColor(.white)
                .padding(.bottom, 10)

            Text("Genre: \(song.genre ?? "Unknown Genre")")
                .foregroundColor(.white)
                .padding(.bottom, 10)

            Spacer()
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }

    // Helper function to format time duration
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - SearchBar

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.leading, 30)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        Spacer()
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isSearching = true
                }

            if isSearching {
                Button(action: {
                    self.text = ""
                    self.isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // Dismiss keyboard
                }) {
                    Text("Cancel")
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 10)
            }
        }
    }
}
