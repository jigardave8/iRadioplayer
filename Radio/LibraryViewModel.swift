//
//  LibraryViewModel.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//

import Foundation
import MediaPlayer

class LibraryViewModel: ObservableObject {
    static let shared = LibraryViewModel()

    @Published var songs: [MPMediaItem] = []
    @Published var selectedSong: MPMediaItem?

    func fetchSongs() {
        let query = MPMediaQuery.songs()
        if let items = query.items {
            songs = items
        }
    }
    
    
    
    
    
    func filteredSongs(searchText: String) -> [MPMediaItem] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { song in
                let searchLowercased = searchText.lowercased()
                return song.title?.lowercased().contains(searchLowercased) == true ||
                    song.artist?.lowercased().contains(searchLowercased) == true ||
                    song.albumTitle?.lowercased().contains(searchLowercased) == true
            }
        }
    }
}
