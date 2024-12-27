//
//  RadioView.swift
//  Radio
//
//  Created by Jigar on 03/10/23.
//


import SwiftUI
import WebKit
import AVFoundation

struct RadioView: View {
    @State private var selectedRadioStation = "Radio Paradise (RP)"
    @State private var webViewURL: URL?
    @State private var avPlayer: AVPlayer?
    @State private var volume: Float = 0.5 // Default volume
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Header with colorful gradient
                Text("Live Internet Radio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                
                // Radio Station Picker with Custom Background
                Picker("Radio Station", selection: $selectedRadioStation) {
                    ForEach(RadioStations.stations.keys.sorted(), id: \.self) { radioStation in
                        Text(radioStation)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding(.horizontal, 20)
                .frame(height: 160) // Adjustable height
                
                // Play Button
                Button(action: {
                    if let url = URL(string: RadioStations.stations[selectedRadioStation]!) {
                        webViewURL = url
                        let player = AVPlayer(url: url)
                        self.avPlayer = player
                        player.play()
                    }
                }) {
                    Text("Play")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 20)
                
                // Volume Slider with Custom Color
                Slider(value: $volume, in: 0...1)
                    .accentColor(.cyan)
                    .padding(.horizontal)
                    .onChange(of: volume) { newVolume in
                        avPlayer?.volume = newVolume
                    }
                
                // Pause and Stop Buttons with New Gradient and Hover Effects
                HStack(spacing: 20) {
                    Button(action: {
                        avPlayer?.pause()
                    }) {
                        Text("Pause")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        avPlayer?.replaceCurrentItem(with: nil)
                        webViewURL = nil
                    }) {
                        Text("Stop")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 20)
                
                // Fixed View for WebView (always takes the same space)
                ZStack {
                    if let _ = webViewURL {
                        ScrollView {
                            WebView(url: webViewURL!)
                                .frame(height: 250) // Fixed height for the WebView
                                .cornerRadius(15)
                                .shadow(radius: 10)
                                .padding(.horizontal, 20)
                        }
                        .frame(height: 250) // Keep fixed height even if WebView is empty
                        .transition(.move(edge: .top).combined(with: .opacity)) // Smooth transition
                        .animation(.easeInOut(duration: 0.5), value: webViewURL != nil)
                    } else {
                        Color.clear.frame(height: 250) // Placeholder for fixed space
                    }
                }
                
                Spacer() // Flexible space for layout adjustments
            }
            .padding(.bottom, 20)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("Radio Stations", displayMode: .inline)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
