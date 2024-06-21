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

    var body: some View {
        VStack {
            Text("Media Library")
                .font(.title3)
                .fontWeight(.bold)
                .padding(2)

            // Search Bar
            SearchBar(text: $searchText, isSearching: $isSearching)
                .padding(.horizontal)
                .onTapGesture {
                    isSearching = true // Tap on search bar starts searching
                }

            List {
                ForEach(libraryViewModel.filteredSongs(searchText: searchText), id: \.persistentID) { song in
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
    }
}
