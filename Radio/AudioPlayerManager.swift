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
    @Published var currentEqualizerSetting: EqualizerSetting = .normal {
        didSet {
            applyEqualizerSetting()
        }
    }

    private var audioPlayer: AVAudioPlayer?
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var audioEngine: AVAudioEngine?
    private var eqNodes: [AVAudioUnitEQ] = []

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

    override init() {
        super.init()
        setupAudioSession()
        setupAudioEngine()
    }

    public func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session:", error.localizedDescription)
        }
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        eqNodes = EqualizerSetting.allCases.map { _ in
            let eq = AVAudioUnitEQ(numberOfBands: 10)
            audioEngine?.attach(eq)
            return eq
        }

        if let audioEngine = audioEngine {
            for i in 0..<eqNodes.count {
                audioEngine.connect(eqNodes[i], to: i == eqNodes.count - 1 ? audioEngine.mainMixerNode : eqNodes[i + 1], format: nil)
            }
        }

        applyEqualizerSetting()
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

    private func startUpdatingCurrentTime() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }
        timer?.fire()
    }

    private func updateCurrentTime() {
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
        if let player = audioPlayer, player.isPlaying {
            player.pause()
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
        guard let audioEngine = audioEngine else { return }

        for eq in eqNodes {
            for band in eq.bands {
                band.filterType = .parametric
                band.bypass = true
            }
        }

        switch currentEqualizerSetting {
        case .normal:
            break
        case .rock:
            applyBandsSettings([3.0, 2.5, 2.0, 1.5, 1.0])
        case .pop:
            applyBandsSettings([2.0, 2.0, 2.0, 1.0, 1.0])
        case .jazz:
            applyBandsSettings([2.5, 2.0, 1.5, 1.0, 1.0])
        case .bass:
            applyBandsSettings([4.0, 3.5, 3.0, 2.5, 2.0])
        case .treble:
            applyBandsSettings([1.5, 1.0, 0.5, 0.0, 0.0])
        case .bassAndTreble:
            applyBandsSettings([3.5, 3.0, 2.5, 2.0, 1.5])
        case .classical:
            applyBandsSettings([2.0, 1.5, 1.0, 0.5, 0.5])
        case .hipHop:
            applyBandsSettings([3.0, 2.5, 2.0, 1.5, 1.5])
        case .reset:
            applyBandsSettings([0.0, 0.0, 0.0, 0.0, 0.0])
        }

        audioEngine.mainMixerNode.outputVolume = audioLevels
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine:", error.localizedDescription)
        }
    }

    private func applyBandsSettings(_ values: [Float]) {
        for (index, value) in values.enumerated() {
            if index < eqNodes.count {
                let eq = eqNodes[index]
                for band in eq.bands {
                    band.gain = value
                    band.bypass = false
                }
            }
        }
    }

    var currentPlaybackTime: Double {
        return audioPlayer?.currentTime ?? 0
    }

    var currentSongDuration: Double {
        return audioPlayer?.duration ?? 0
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playNext()
    }
}
