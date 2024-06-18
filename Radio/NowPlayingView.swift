//
//  NowPlayingView.swift
//  Radio
//
//  Created by Jigar on 18/06/24.
//
//
//  NowPlayingView.swift
//  Radio
//
//  Created by Jigar on 18/06/24.
//
import SwiftUI
import MediaPlayer

struct NowPlayingView: View {
    @ObservedObject var audioPlayerManager: AudioPlayerManager
    @State private var currentTime: TimeInterval = 0
    @State private var isSeeking = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                if let currentSong = getCurrentSong() {
                    // Album Art
                    AlbumArtView(albumArt: currentSong.artwork?.image(at: CGSize(width: 400, height: 250)))
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                        .padding(.top, 20)
                    
                    // Song Information
                    VStack(spacing: 8) {
                        Text(currentSong.title ?? "Unknown Title")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text(currentSong.artist ?? "Unknown Artist")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text(currentSong.albumTitle ?? "Unknown Album")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Current Time and Duration
                    HStack {
                        Text("\(formattedTime(time: currentTime))")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(formattedTime(time: audioPlayerManager.currentSongDuration))")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)

                    // Playback Slider
                    Slider(value: Binding(
                        get: { currentTime },
                        set: { newTime in
                            audioPlayerManager.seek(to: newTime)
                            currentTime = newTime
                        }
                    ), in: 0...(audioPlayerManager.currentSongDuration ?? 1))
                    .accentColor(.red)
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
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.6))
                                .shadow(radius: 5)
                        )
                        .padding()
                }
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
            )
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
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
}

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

// Preview for SwiftUI canvas
struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingView(audioPlayerManager: AudioPlayerManager())
            .preferredColorScheme(.dark) // To better visualize the dark theme
    }
}
