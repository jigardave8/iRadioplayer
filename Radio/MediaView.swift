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
                                                .background(Color.white)
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
                    .animation(.easeInOut)

                    // Main Content Area
                    VStack {
                        // Now Playing View
                        NowPlayingView(audioPlayerManager: audioPlayerManager)

                        // Music Player Controls
                        HStack(spacing: 20) {
                            Spacer()
                            Button(action: {
                                audioPlayerManager.shuffle()
                            }) {
                                Image(systemName: "shuffle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(25)
                            }
                            Button(action: {
                                audioPlayerManager.playPrevious()
                            }) {
                                Image(systemName: "backward.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(25)
                            }
                            Button(action: {
                                audioPlayerManager.togglePlayPause()
                            }) {
                                Image(systemName: audioPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding(16)
                                    .background(Color.green)
                                    .cornerRadius(35)
                            }
                            Button(action: {
                                audioPlayerManager.playNext()
                            }) {
                                Image(systemName: "forward.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(25)
                            }
                            Button(action: {
                                audioPlayerManager.stop()
                            }) {
                                Image(systemName: "stop.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(25)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
                .navigationBarItems(leading:
                    Button(action: {
                        withAnimation {
                            self.isSidebarExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isSidebarExpanded ? "chevron.left" : "sidebar.left")
                            .padding()
                    },
                trailing:
                    HStack(spacing: 20) {
                        NavigationLink(destination: SettingsView(audioPlayerManager: audioPlayerManager)) {
                            Image(systemName: "gear")
                                .padding()
                        }
                        Button(action: {
                            // Implement custom action for the star button
                        }) {
                            Image(systemName: "star.fill")
                                .padding()
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
}
