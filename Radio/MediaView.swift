//
//  MediaView.swift
//  Radio
//
//  Created by Jigar on 21/06/24.
//

import SwiftUI

struct MediaView: View {
    @ObservedObject var libraryViewModel = LibraryViewModel.shared
    @ObservedObject var audioPlayerManager = AudioPlayerManager.shared

    @State private var isSidebarExpanded = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var currentGradientIndex = 0
    @State private var useDedicatedGradient = false
    @State private var animationPhase = 0.0
    @State private var isSettingsViewPresented = false
    @State private var isMediaLibraryViewPresented = false
    @State private var isVisualizerViewPresented = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: 0) {
                        VStack {
                            NowPlayingView(audioPlayerManager: audioPlayerManager)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: useDedicatedGradient ? (currentGradientIndex == 0 ? dedicatedGradient : lightGradient) : gradients[currentGradientIndex]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                )
                                .padding()
                            
                            HStack {
                                Text(timeString(time: audioPlayerManager.currentPlaybackTime))
                                    .foregroundColor(.white)
                                Slider(value: Binding(get: {
                                    self.audioPlayerManager.currentPlaybackTime
                                }, set: { newTime in
                                    self.audioPlayerManager.seek(to: newTime)
                                }), in: 0...self.audioPlayerManager.currentSongDuration)
                                .accentColor(.green)
                                Text("-\(timeString(time: audioPlayerManager.currentSongDuration - audioPlayerManager.currentPlaybackTime))")
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 5)
                            .padding(.bottom, 1)

                            HStack(spacing: 20) {
                                controlButton(iconName: "shuffle", action: audioPlayerManager.shuffle, color: .black)
                                controlButton(iconName: "backward.fill", action: audioPlayerManager.playPrevious, color: .gray)
                                controlButton(iconName: audioPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill", action: audioPlayerManager.togglePlayPause, color: .black, size: 40)
                                controlButton(iconName: "forward.fill", action: audioPlayerManager.playNext, color: .gray)
                                controlButton(iconName: "stop.fill", action: audioPlayerManager.stop, color: .red)
                                controlButton(iconName: "paintbrush.fill", action: {
                                    useDedicatedGradient = false
                                    currentGradientIndex = (currentGradientIndex + 1) % gradients.count
                                }, color: .blue)
                                controlButton(iconName: "circle.lefthalf.fill", action: {
                                    useDedicatedGradient.toggle()
                                    currentGradientIndex = 0
                                }, color: .purple)
                            }
                            .padding()
                        }
                        .background(
                            ZStack {
                                if useDedicatedGradient {
                                    AngularGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.red]), center: .center, angle: .degrees(animationPhase))
                                        .opacity(0.5)
                                        .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: animationPhase)
                                        .onAppear {
                                            animationPhase += 360
                                        }
                                } else {
                                    LinearGradient(gradient: Gradient(colors: gradients[currentGradientIndex]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .edgesIgnoringSafeArea(.all)
                                }
                            }
                        )
                    }

                    if isSearching {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isSearching = false
                                searchText = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    }
                }
                .navigationBarItems(
//                    leading: Button(action: {
//                        withAnimation {
//                            isSidebarExpanded.toggle()
//                        }
//                    }) {
//                        Image(systemName: "line.horizontal.3")
//                            .imageScale(.large)
//                    },
                    trailing: HStack {
                        Button(action: {
                            isMediaLibraryViewPresented.toggle()
                        }) {
                            Image(systemName: "music.note.list")
                                .imageScale(.large)
                        }
                        Button(action: {
                            isVisualizerViewPresented.toggle()
                        }) {
                            Image(systemName: "waveform.path.ecg")
                                .imageScale(.large)
                        }
                        Button(action: {
                            isSettingsViewPresented.toggle()
                        }) {
                            Image(systemName: "headphones.circle")
                                .imageScale(.large)
                        }
                    }
                )
                .sheet(isPresented: $isSettingsViewPresented) {
                    SettingsView(audioPlayerManager: audioPlayerManager)
                }
                .sheet(isPresented: $isMediaLibraryViewPresented) {
                    MediaLibraryView()
                }
                .sheet(isPresented: $isVisualizerViewPresented) {
                    VisualizerView(scene: VisualizerScene(size: geometry.size))
                }
                .onAppear {
                    libraryViewModel.fetchSongs()
                    audioPlayerManager.setupAudioSession()
                }
            }
        }
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @ViewBuilder
    private func controlButton(iconName: String, action: @escaping () -> Void, color: Color, size: CGFloat = 30) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
    }
}
