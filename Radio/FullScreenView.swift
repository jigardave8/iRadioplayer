//
//  FullScreenView.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//

import SwiftUI
import AVFoundation
import MediaPlayer

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

