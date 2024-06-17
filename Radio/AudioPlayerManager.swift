//
//  AudioPlayerManager.swift
//  Radio
//
//  Created by Jigar on 17/06/24.
//

import SwiftUI
import AVFoundation
import MediaPlayer

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()

    @Published var isPlaying: Bool = false
    @Published var audioLevels: Float = 0.0
    @Published var showSettings: Bool = false
    var audioPlayer: AVAudioPlayer?
    var currentIndex: Int = 0

    // Equalizer settings
    enum EqualizerSetting: String, CaseIterable {
        case normal = "Normal"
        case rock = "Rock"
        case pop = "Pop"
        case jazz = "Jazz"
        case bass = "Bass"
        case treble = "Treble"
        case bassAndTreble = "Bass & Treble"
        case classical = "Classical"
        case hipHop = "Hip-Hop"
        case reset = "Reset"
    }

    @Published var currentEqualizerSetting: EqualizerSetting = .normal {
        didSet {
            applyEqualizerSetting()
        }
    }

    private var audioEngine: AVAudioEngine?
    private var eqNodes: [AVAudioUnitEQ] = []

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session:", error.localizedDescription)
        }
    }

    func play(song: MPMediaItem) {
        guard let url = song.assetURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play audio:", error.localizedDescription)
        }
    }

    func playNext() {
        currentIndex = (currentIndex + 1) % LibraryViewModel.shared.songs.count
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    func playPrevious() {
        currentIndex = (currentIndex - 1 + LibraryViewModel.shared.songs.count) % LibraryViewModel.shared.songs.count
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    func togglePlayPause() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
        }
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }

    func shuffle() {
        LibraryViewModel.shared.songs.shuffle()
        currentIndex = 0
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    private func applyEqualizerSetting() {
        // Apply equalizer settings using AVAudioEngine and AVAudioUnitEQ
        // This is a placeholder for actual equalizer settings implementation
    }
}
