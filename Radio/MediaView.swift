//
//  MediaView.swift
//  Radio
//
//  Created by Jigar on 03/10/23.
//

import SwiftUI

struct MediaView: View {
    @ObservedObject var libraryViewModel = LibraryViewModel.shared
    @ObservedObject var audioPlayerManager = AudioPlayerManager.shared

    @State private var isSidebarExpanded = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Side Panel (Collapsible)
                    VStack {
                        Text("Media Library")
                            .font(.headline)
                            .padding()
                        List {
                            ForEach(libraryViewModel.songs, id: \.persistentID) { song in
                                Button(action: {
                                    libraryViewModel.selectedSong = song
                                    audioPlayerManager.play(song: song)
                                }) {
                                    HStack {
                                        Text(song.title ?? "Unknown Title")
                                            .foregroundColor(song == libraryViewModel.selectedSong ? .blue : .black)
                                            .padding(8)
                                            .background(song == libraryViewModel.selectedSong && audioPlayerManager.isPlaying ? Color.yellow : Color.white)
                                            .cornerRadius(8)
                                        Spacer()
                                        if song == libraryViewModel.selectedSong && audioPlayerManager.isPlaying {
                                            Image(systemName: "speaker.wave.2.fill")
                                                .foregroundColor(.green)
                                                .padding(8)
                                                .background(Color.gray)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        .onAppear {
                            libraryViewModel.fetchSongs()
                        }
                    }
                    .frame(width: isSidebarExpanded ? geometry.size.width * 0.6 : 0)
                    .background(Color.gray.opacity(0.1))
                    .animation(.easeInOut)

                    // Main Content Area
                    VStack {
                        // Now Playing View
                        NowPlayingView(audioPlayerManager: audioPlayerManager)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.6)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            )
                            .padding()
                        
                        // Music Player Controls
                        HStack(spacing: 20) {
                            Spacer()
                            controlButton(iconName: "shuffle", action: audioPlayerManager.shuffle, color: .orange)
                            controlButton(iconName: "backward.fill", action: audioPlayerManager.playPrevious, color: .blue)
                            controlButton(iconName: audioPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill", action: audioPlayerManager.togglePlayPause, color: .green, size: 30)
                            controlButton(iconName: "forward.fill", action: audioPlayerManager.playNext, color: .blue)
                            controlButton(iconName: "stop.fill", action: audioPlayerManager.stop, color: .red)
                            Spacer()
                        }
                        .padding()
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                    )
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
                .navigationBarItems(leading:
                    Button(action: {
                        withAnimation {
                            self.isSidebarExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isSidebarExpanded ? "chevron.left" : "sidebar.left")
                            .padding()
                            .foregroundColor(.red)
                    },
                trailing:
                    HStack(spacing: 20) {
                        NavigationLink(destination: SettingsView(audioPlayerManager: audioPlayerManager)) {
                            Image(systemName: "gear")
                                .padding()
                                .foregroundColor(.black)
                        }
                        Button(action: {
                            // Implement custom action for the star button
                        }) {
                            Image(systemName: "star.fill")
                                .padding()
                                .foregroundColor(.yellow)
                        }
                    }
                )
            }
            .onAppear {
                audioPlayerManager.setupAudioSession()
            }
            .sheet(isPresented: $audioPlayerManager.showSettings) {
                SettingsView(audioPlayerManager: audioPlayerManager)
            }
        }
    }

    @ViewBuilder
    private func controlButton(iconName: String, action: @escaping () -> Void, color: Color, size: CGFloat = 20) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: size, height: size)
                .padding(12)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(size)
                .shadow(radius: 5)
        }
    }
}
