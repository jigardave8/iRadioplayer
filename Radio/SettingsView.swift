//
//  SettingsView.swift
//  Radio
//
//  Created by Jigar on 17/06/24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var audioPlayerManager: AudioPlayerManager

    var body: some View {
        VStack {
            Text("Equalizer Settings")
                .font(.headline)
                .padding()

            Picker("Equalizer", selection: $audioPlayerManager.currentEqualizerSetting) {
                ForEach(AudioPlayerManager.EqualizerSetting.allCases, id: \.self) { setting in
                    Text(setting.rawValue).tag(setting)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            )
            .foregroundColor(.white)

            Button(action: {
                audioPlayerManager.showSettings = false
            }) {
                Text("Done")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
