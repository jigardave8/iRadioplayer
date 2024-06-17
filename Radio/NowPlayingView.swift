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
            } else {
                Text("No song selected")
                    .font(.title)
                    .padding()
            }
        }
    }
}
