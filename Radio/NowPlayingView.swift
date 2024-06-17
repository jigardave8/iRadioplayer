//
//  NowPlayingView.swift
//  Radio
//
//  Created by Jigar on 18/06/24.
//
import SwiftUI

struct NowPlayingView: View {
    @ObservedObject var audioPlayerManager: AudioPlayerManager
    
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
                
                VStack(spacing: 5) {
                    Text(currentSong.title ?? "Unknown Title")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Text(currentSong.artist ?? "Unknown Artist")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Text(currentSong.albumTitle ?? "Unknown Album")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                
                ProgressView(value: audioPlayerManager.audioPlayer?.currentTime ?? 0, total: audioPlayerManager.audioPlayer?.duration ?? 1)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .padding(.horizontal)
                
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
            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(10)
                .shadow(radius: 5)
        )
        .padding()
    }
}
