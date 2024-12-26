import SwiftUI
import MediaPlayer

struct MediaLibraryView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var libraryViewModel = LibraryViewModel.shared
    @ObservedObject var audioPlayerManager = AudioPlayerManager.shared
    
    // MARK: - State
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var currentGradientIndex = 0
    @State private var useDedicatedGradient = false
    @State private var animationPhase = 0.0
    @State private var selectedCategory: MediaCategory = .all
    
    // MARK: - Enums
    enum MediaCategory: String, CaseIterable {
        case all = "All"
        case recent = "Recent"
        case favorites = "Favorites"
        case playlists = "Playlists"
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                
                VStack(spacing: 0) {
                    headerView
                    categorySelector
                    searchBarView
                    songListView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { sortByTitle() }) {
                            Label("Sort by Title", systemImage: "textformat")
                        }
                        Button(action: { sortByArtist() }) {
                            Label("Sort by Artist", systemImage: "music.mic")
                        }
                        Button(action: { sortByDuration() }) {
                            Label("Sort by Duration", systemImage: "clock")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    private var backgroundView: some View {
        Group {
            if useDedicatedGradient {
                AnimatedGradientBackground(phase: animationPhase)
            } else {
                StaticGradientBackground(gradientIndex: currentGradientIndex)
            }
        }
        .ignoresSafeArea()
    }
    
    private var headerView: some View {
        VStack {
            Text("Media Library")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .shadow(radius: 5)
                )
        }
        .padding(.top)
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(MediaCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    private var searchBarView: some View {
        CustomSearchBar(
            text: $searchText,
            isSearching: $isSearching,
            placeholder: "Search songs..."
        )
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private var songListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(filteredSongs, id: \.persistentID) { song in
                    SongRowView(
                        song: song,
                        isPlaying: song == libraryViewModel.selectedSong && audioPlayerManager.isPlaying,
                        isSelected: song == libraryViewModel.selectedSong
                    ) {
                        playSong(song)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    private var filteredSongs: [MPMediaItem] {
        let songs = libraryViewModel.filteredSongs(searchText: searchText)
        switch selectedCategory {
        case .all:
            return songs
        case .recent:
            return Array(songs.prefix(10)) // Show last 10 played songs
        case .favorites:
            return songs.filter { _ in /* Add your favorite logic here */ true }
        case .playlists:
            return songs // Implement playlist filtering
        }
    }
    
    // MARK: - Methods
    private func playSong(_ song: MPMediaItem) {
        libraryViewModel.selectedSong = song
        audioPlayerManager.play(song: song)
    }
    
    private func sortByTitle() {
        libraryViewModel.sortSongs(by: { ($0.title ?? "").lowercased() < ($1.title ?? "").lowercased() })
    }
    
    private func sortByArtist() {
        libraryViewModel.sortSongs(by: { ($0.artist ?? "").lowercased() < ($1.artist ?? "").lowercased() })
    }
    
    private func sortByDuration() {
        libraryViewModel.sortSongs(by: { $0.playbackDuration < $1.playbackDuration })
    }
}

// MARK: - Supporting Views
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.3))
                )
                .foregroundColor(isSelected ? .black : .white)
        }
    }
}

struct CustomSearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isSearching = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
    }
}

struct SongRowView: View {
    let song: MPMediaItem
    let isPlaying: Bool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Album Artwork
                AlbumArtworkView(artwork: song.artwork)
                
                // Song Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title ?? "Unknown Title")
                        .font(.headline)
                        .foregroundColor(isSelected ? .blue : .primary)
                        .lineLimit(1)
                    
                    Text(song.artist ?? "Unknown Artist")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Playing Indicator
                if isPlaying {
                    PlayingIndicatorView()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.white.opacity(0.9))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AlbumArtworkView: View {
    let artwork: MPMediaItemArtwork?
    
    var body: some View {
        Group {
            if let artwork = artwork,
               let image = artwork.image(at: CGSize(width: 50, height: 50)) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "music.note")
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 50, height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct PlayingIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "speaker.wave.2.fill")
            .foregroundColor(.blue)
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Background Views
struct AnimatedGradientBackground: View {
    let phase: Double
    
    var body: some View {
        AngularGradient(
            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]),
            center: .center,
            angle: .degrees(phase)
        )
        .opacity(0.5)
    }
}

struct StaticGradientBackground: View {
    let gradientIndex: Int
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradients[gradientIndex]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview
struct MediaLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        MediaLibraryView()
    }
}
