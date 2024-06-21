//
//  NowPlayingView.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//

import SwiftUI
import MediaPlayer

struct NowPlayingView: View {
    @ObservedObject var audioPlayerManager: AudioPlayerManager
    @State private var isFullScreen = false // State to manage full-screen mode
    
    
    var body: some View {
        VStack {
            if let song = audioPlayerManager.currentSong {
                Text(song.title ?? "Unknown Title")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(4)
                    .padding(3)
                    
                
                Text(song.artist ?? "Unknown Artist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 1)
                
                if let artwork = song.artwork {
                    Image(uiImage: artwork.image(at: CGSize(width: 250, height: 250)) ?? UIImage(systemName: "music.note")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            isFullScreen.toggle()
                        }
                        .cornerRadius(10)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .padding(.top, 12)
                        .cornerRadius(10)
                }
            } else {
                Text("No song is currently playing.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
            }
        }
        .sheet(isPresented: $isFullScreen) {
            if let song = audioPlayerManager.currentSong {
                FullScreenView(song: song)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 2)
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
