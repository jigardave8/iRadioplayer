//
//  SettingsView.swift
//  Radio
//
//  Created by Jigar on 17/06/24.
//


//import SwiftUI
//
//struct SettingsView: View {
//    @ObservedObject var audioPlayerManager: AudioPlayerManager
//
//    var body: some View {
//        VStack {
//            Text("Equalizer Settings")
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//                .padding(.top, 40)
//                .padding(.bottom, 20)
//
//            Picker("Equalizer", selection: $audioPlayerManager.currentEqualizerSetting) {
//                ForEach(AudioPlayerManager.EqualizerSetting.allCases, id: \.self) { setting in
//                    Text(setting.rawValue)
//                        .foregroundColor(.white)
//                        .tag(setting)
//                }
//            }
//            .pickerStyle(WheelPickerStyle())
//            .background(
//                LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.black.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                    .cornerRadius(10)
//                    .shadow(radius: 5)
//            )
//            .padding(.horizontal, 40)
//            .padding(.bottom, 40)
//            .frame(height: 200)
//
//            Button(action: {
//                audioPlayerManager.showSettings = false
//            }) {
//                Text("Done")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.red)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .padding(.horizontal, 40)
//                    .shadow(radius: 5)
//            }
//            .padding(.bottom, 40)
//        }
//        .background(
//            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom)
//                .edgesIgnoringSafeArea(.all)
//        )
//    }
//}
//
//// Preview for SwiftUI canvas
//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(audioPlayerManager: AudioPlayerManager())
//            .preferredColorScheme(.dark)
//    }
//}
