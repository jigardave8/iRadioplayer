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
    
    @GestureState private var dragState = DragState.inactive // Gesture state for tracking drag gestures
    @State private var offset: CGFloat = 0 // Offset to animate album art
    
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
                        Image(uiImage: artwork.image(at: CGSize(width: 250, height: 250)) ?? UIImage(systemName: "music.note")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .offset(x: offset) // Apply offset for animation
                            .cornerRadius(10)
                            .gesture(
                                DragGesture()
                                    .updating($dragState, body: { (value, state, _) in
                                        state = .dragging(translation: value.translation.width)
                                    })
                                    .onEnded({ (value) in
                                        let dragThreshold: CGFloat = 100
                                        if value.translation.width > dragThreshold {
                                            audioPlayerManager.playPrevious()
                                        } else if value.translation.width < -dragThreshold {
                                            audioPlayerManager.playNext()
                                        }
                                    })
                            )
                            .animation(.interpolatingSpring)
                            .onChange(of: audioPlayerManager.currentSong) { _ in
                                withAnimation {
                                    offset = 0.1 // Reset offset when song changes
                                }
                            }
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .padding(.top, 5)
                            .cornerRadius(10)
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

// Gesture state for tracking drag gestures
private enum DragState {
    case inactive
    case dragging(translation: CGFloat)
}
