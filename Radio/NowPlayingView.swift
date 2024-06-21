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
                    .padding(1)
                
                Text(song.artist ?? "Unknown Artist")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 1)
                
                ZStack {
                    if let artwork = song.artwork {
                        GeometryReader { geometry in
                            Image(uiImage: artwork.image(at: CGSize(width: 250, height: 250)) ?? UIImage(systemName: "music.note")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .padding(.bottom, 5)
                                .cornerRadius(10)
                                .onTapGesture {
                                    isFullScreen.toggle()
                                }
                        }
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .padding(.top, 5)
                            .cornerRadius(10)
                            .onTapGesture {
                                isFullScreen.toggle()
                            }
                    }
                }
                .frame(width: 250, height: 250)
                .background(Color.black)
                .cornerRadius(10)
                .shadow(radius: 5)
                
            } else {
                Text("No song is currently playing.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 5)
        .sheet(isPresented: $isFullScreen) {
            if let song = audioPlayerManager.currentSong {
                FullScreenView(song: song)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
