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
