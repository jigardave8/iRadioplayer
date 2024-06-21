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
            .navigationBarTitle("Music Player", displayMode: .inline)
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

    var body: some View {
        VStack {
            Text(audioPlayerManager.currentSong?.title ?? "No Song Selected")
                .font(.title)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .foregroundColor(.white)

            if let artwork = audioPlayerManager.currentSong?.artwork {
                Image(uiImage: artwork.image(at: CGSize(width: 300, height: 300))!)
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

            // Slider for current time
            Slider(value: Binding(
                get: { audioPlayerManager.currentTime },
                set: { newValue in audioPlayerManager.seek(to: newValue) }
            ), in: 0...audioPlayerManager.currentSongDuration)
                .accentColor(.white)
                .padding()
        }
    }
}

// MARK: - SearchBar

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var isSearching: Bool

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isSearching: Bool

        init(text: Binding<String>, isSearching: Binding<Bool>) {
            _text = text
            _isSearching = isSearching
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            isSearching = true
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            isSearching = false
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            isSearching = false
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            isSearching = false
            text = ""
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isSearching: $isSearching)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search"
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

// MARK: - Preview

struct MediaView_Previews: PreviewProvider {
    static var previews: some View {
        MediaView()
    }
}
