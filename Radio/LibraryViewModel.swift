//
//  LibraryViewModel.swift
//  Radio
//
//  Created by Jigar on 17/06/24.
//

import SwiftUI
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
}
