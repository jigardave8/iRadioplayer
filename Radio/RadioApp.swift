//
//  RadioApp.swift
//  Radio
//
//  Created by Jigar on 18/09/23.
//

import SwiftUI

@main
struct RadioApp: App {
//    let libraryViewModel = LibraryViewModel.shared
//    let audioPlayerManager = AudioPlayerManager.shared
    @StateObject private var libraryViewModel = LibraryViewModel.shared
    @StateObject private var audioPlayerManager = AudioPlayerManager.shared
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(libraryViewModel)
                .environmentObject(audioPlayerManager)
        }
    }
}
