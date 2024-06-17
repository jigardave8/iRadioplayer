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
        VStack {
            if let currentSong = audioPlayerManager.currentIndex < LibraryViewModel.shared.songs.count ? LibraryViewModel.shared.songs[audioPlayerManager.currentIndex] : nil {
                Text(currentSong.title ?? "Unknown Title")
                    .font(.title)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    )
                    .foregroundColor(.white)
                    .padding()
            } else {
                Text("No song selected")
                    .font(.title)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    )
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
