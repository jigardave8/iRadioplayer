//
//  AudioPlayerManager.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()

    @Published var isPlaying: Bool = false
    @Published var audioLevels: Float = 0.0
    @Published var showSettings: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var currentSong: MPMediaItem?

    var audioPlayer: AVAudioPlayer?
    var currentIndex: Int = 0

    private var timer: Timer?
    let currentTimePublisher = PassthroughSubject<TimeInterval, Never>()

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
            currentSong = song
            LibraryViewModel.shared.selectedSong = song
            startUpdatingCurrentTime()
        } catch {
            print("Failed to play audio:", error.localizedDescription)
        }
    }

    func startUpdatingCurrentTime() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateCurrentTime()
        }
        timer?.fire()
    }

    func updateCurrentTime() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
        currentTimePublisher.send(currentTime)
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
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
            startUpdatingCurrentTime()
        }
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    func shuffle() {
        LibraryViewModel.shared.songs.shuffle()
        currentIndex = 0
        play(song: LibraryViewModel.shared.songs[currentIndex])
    }

    private func applyEqualizerSetting() {
        // Placeholder for actual equalizer settings implementation
    }

    var currentPlaybackTime: Double {
        return audioPlayer?.currentTime ?? 0
    }

    var currentSongDuration: Double {
        return audioPlayer?.duration ?? 0
    }
}
