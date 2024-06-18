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
    @State private var volume: Float = 0.5 // Adjust this value as needed

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Live Internet Radio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Picker("Radio Station", selection: $selectedRadioStation) {
                    ForEach(RadioStations.stations.keys.sorted(), id: \.self) { radioStation in
                        Text(radioStation)
                            .foregroundColor(.white)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.black.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                )
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .frame(height: 125) // Fixed height for the picker
                
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
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 20)
                
                Slider(value: $volume, in: 0...1)
                    .accentColor(.blue)
                    .padding(.horizontal)
                    .onChange(of: volume) { newVolume in
                        avPlayer?.volume = newVolume
                    }
                
                HStack {
                    Button(action: {
                        avPlayer?.pause()
                    }) {
                        Text("Pause")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
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
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 20)

                if let url = webViewURL {
                    ScrollView{
                        WebView(url: url)
                            .frame(height: 200) // Fixed height for WebView
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.horizontal, 20)
                    }
                   
                } else {
                    Color.clear.frame(height: 150) // Placeholder to keep layout consistent
                }

//                Spacer() // Push content to the top
            }
            .padding(.bottom, 10)
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
