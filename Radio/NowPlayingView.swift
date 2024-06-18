//
//  NowPlayingView.swift
//  Radio
//
//  Created by Jigar on 18/06/24.
//
import SwiftUI

struct NowPlayingView: View {
    @ObservedObject var audioPlayerManager: AudioPlayerManager
    @State private var currentTime: TimeInterval = 0
    @State private var isSeeking = false

    var body: some View {
        VStack(spacing: 20) {
            if let currentSong = audioPlayerManager.currentIndex < LibraryViewModel.shared.songs.count ? LibraryViewModel.shared.songs[audioPlayerManager.currentIndex] : nil {
                
                if let artwork = currentSong.artwork {
                    Image(uiImage: artwork.image(at: CGSize(width: 200, height: 200))!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
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
                
                Slider(value: Binding(
                    get: { currentTime },
                    set: { newTime in
                        audioPlayerManager.seek(to: newTime)
                        currentTime = newTime
                    }
                ), in: 0...(audioPlayerManager.audioPlayer?.duration ?? 1))
                .accentColor(.orange)
                .padding(.horizontal)
                .onReceive(audioPlayerManager.currentTimePublisher) { time in
                    if !isSeeking {
                        currentTime = time
                    }
                }
                
            } else {
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
            GeometryReader { geometry in
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .edgesIgnoringSafeArea(.all)
        )
        .padding()
        .onAppear {
            audioPlayerManager.updateCurrentTime()
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
