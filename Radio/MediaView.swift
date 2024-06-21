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
    @State private var isSearching = false // Track if the user is actively searching
    @State private var currentGradientIndex = 0 // Track the current gradient index
    @State private var useDedicatedGradient = false // Track if the dedicated gradient is used
    @State private var animationPhase = 0.0 // Phase for the animation
    @State private var isSettingsViewPresented = false // State to control the presentation of SettingsView

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack { // Use ZStack to handle taps outside the search bar
                    HStack(spacing: 0) {
                        // Side Panel (Collapsible)
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
                        .frame(width: isSidebarExpanded ? geometry.size.width * 0.6 : 0)
                        .background(Color.gray.opacity(0.1))
                        .animation(.linear)

                        // Main Content Area
                        VStack {
                            // Now Playing View
                            NowPlayingView(audioPlayerManager: audioPlayerManager)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: useDedicatedGradient ? (currentGradientIndex == 0 ? dedicatedGradient : lightGradient) : gradients[currentGradientIndex]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                )
                                .padding()
                                .gesture(
                                    DragGesture()
                                        .onEnded({ (value) in
                                            let dragThreshold: CGFloat = 100
                                            if value.translation.width > dragThreshold {
                                                audioPlayerManager.playPrevious()
                                            } else if value.translation.width < -dragThreshold {
                                                audioPlayerManager.playNext()
                                            }
                                        })
                                )
                            
                            HStack {
                                Text(timeString(time: audioPlayerManager.currentPlaybackTime))
                                    .foregroundColor(.white)
                                Slider(value: Binding(get: {
                                    self.audioPlayerManager.currentPlaybackTime
                                }, set: { (newTime) in
                                    self.audioPlayerManager.seek(to: newTime)
                                }), in: 0...self.audioPlayerManager.currentSongDuration)
                                .accentColor(.green)
                                Text("-\(timeString(time: audioPlayerManager.currentSongDuration - audioPlayerManager.currentPlaybackTime))")
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 5)
                            .padding(.bottom, 1)

                            // Music Player Controls
                            HStack(spacing: 20) {
                                controlButton(iconName: "shuffle", action: audioPlayerManager.shuffle, color: .black)
                                controlButton(iconName: "backward.fill", action: audioPlayerManager.playPrevious, color: .gray)
                                controlButton(iconName: audioPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill", action: audioPlayerManager.togglePlayPause, color: .black, size: 40)
                                controlButton(iconName: "forward.fill", action: audioPlayerManager.playNext, color: .gray)
                                controlButton(iconName: "stop.fill", action: audioPlayerManager.stop, color: .red)

                                // Button to change gradient
                                controlButton(iconName: "paintbrush.fill", action: {
                                    useDedicatedGradient = false
                                    currentGradientIndex = (currentGradientIndex + 1) % gradients.count
                                }, color: .blue)

                                // Button to toggle dedicated gradient
                                controlButton(iconName: "circle.lefthalf.fill", action: {
                                    useDedicatedGradient.toggle()
                                    currentGradientIndex = 0 // Reset index to use the dedicated gradient
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
                                }
                            }
                        )
                    }

                    // Dismiss the search view by tapping outside the search bar
                    if isSearching {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isSearching = false
                                searchText = "" // Clear search text when dismissed
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // Dismiss keyboard
                            }
                    }
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation {
                        isSidebarExpanded.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    isSettingsViewPresented.toggle()
                }) {
                    Image(systemName: "headphones.circle")
                        .imageScale(.large)
                }
            )
            .sheet(isPresented: $isSettingsViewPresented) {
                SettingsView(audioPlayerManager: audioPlayerManager)
            }
            .onAppear {
                libraryViewModel.fetchSongs()
                audioPlayerManager.setupAudioSession()
            }
        }
    }
    
    // Control Button Helper Subview
    @ViewBuilder
    func controlButton(iconName: String, action: @escaping () -> Void, color: Color, size: CGFloat = 30) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
    }

    // Helper function to format time duration
    public func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

