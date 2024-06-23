//
//  MediaLibraryView.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//

// MediaLibraryView.swift

import SwiftUI

struct MediaLibraryView: View {
    @ObservedObject var libraryViewModel = LibraryViewModel.shared
    @ObservedObject var audioPlayerManager = AudioPlayerManager.shared

    @State private var searchText = ""
    @State private var isSearching = false
    @State private var currentGradientIndex = 0
    @State private var useDedicatedGradient = false
    @State private var animationPhase = 0.0

    var body: some View {
        VStack {
            // Title with gradient background
            Text("Media Library")
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: useDedicatedGradient ? dedicatedGradient : gradients[currentGradientIndex]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                )
                .padding(.bottom, 10)

            // Search Bar
            SearchBar(text: $searchText, isSearching: $isSearching)
                .padding(.horizontal)
                .onTapGesture {
                    isSearching = true // Tap on search bar starts searching
                }

            // Song List
            List {
                ForEach(libraryViewModel.filteredSongs(searchText: searchText), id: \.persistentID) { song in
                    Button(action: {
                        libraryViewModel.selectedSong = song
                        audioPlayerManager.play(song: song)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(song.title ?? "Unknown Title")
                                    .font(.headline)
                                    .foregroundColor(song == libraryViewModel.selectedSong ? .blue : .black)
                                Text(song.artist ?? "Unknown Artist")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if song == libraryViewModel.selectedSong && audioPlayerManager.isPlaying {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(song == libraryViewModel.selectedSong ? Color.yellow.opacity(0.3) : Color.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(InsetGroupedListStyle())
            .onAppear {
                libraryViewModel.fetchSongs()
            }
        }
        .padding()
        .background(
            ZStack {
                if useDedicatedGradient {
                    AngularGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.red]), center: .center, angle: .degrees(animationPhase))
                        .opacity(0.5)
                        .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: animationPhase)
                        .onAppear {
                            animationPhase += 360
                        }
                        .edgesIgnoringSafeArea(.all)
                } else {
                    LinearGradient(gradient: Gradient(colors: gradients[currentGradientIndex]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        )
    }
}
