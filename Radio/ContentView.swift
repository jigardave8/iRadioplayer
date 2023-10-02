
import SwiftUI
import WebKit
import AVFoundation


// ** Segment Style **

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                RadioView()
            }
            .tabItem {
                Label("Radio", systemImage: "waveform")
            }
            
            NavigationView {
                MediaView()
            }
            .tabItem {
                Label("Media", systemImage: "music.note")
            }
        }
    }
}

// ** List Style **
//struct ContentView: View {
//    @State private var selectedTab: Tab?
//
//    enum Tab: Hashable {
//        case radio
//        case media
//    }
//
//    var body: some View {
//        NavigationView {
//            List(selection: $selectedTab) {
//                NavigationLink(destination: RadioView(), tag: Tab.radio, selection: $selectedTab) {
//                    Label("Radio", systemImage: "waveform")
//                }
//                .tag(Tab.radio)
//                
//                NavigationLink(destination: MediaView(), tag: Tab.media, selection: $selectedTab) {
//                    Label("Media", systemImage: "music.note")
//                }
//                .tag(Tab.media)
//            }
//            .listStyle(SidebarListStyle())
//            .navigationTitle("Multimedia App")
//            .frame(minWidth: 200, idealWidth: 250, maxWidth: .infinity)
//            
//            if let selectedTab = selectedTab {
//                switch selectedTab {
//                case .radio:
//                    RadioView()
//                case .media:
//                    MediaView()
//                }
//            } else {
//                Text("Select a tab to view content")
//            }
//        }
//    }
//}


//// ** Bottom Colour Style **
//
//struct ContentView: View {
//    @State private var selectedTab: Tab = .radio
//    
//    enum Tab: String, CaseIterable {
//        case radio = "Radio"
//        case media = "Media"
//        
//        var icon: String {
//            switch self {
//            case .radio:
//                return "radio"
//            case .media:
//                return "music.note"
//            }
//        }
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            Spacer()
//            
//            switch selectedTab {
//            case .radio:
//                RadioView()
//            case .media:
//                MediaView()
//            }
//            
//            Spacer()
//            
//            HStack(spacing: 0) {
//                ForEach(Tab.allCases, id: \.self) { tab in
//                    Button(action: {
//                        withAnimation {
//                            selectedTab = tab
//                        }
//                    }) {
//                        VStack {
//                            Image(systemName: tab.icon)
//                                .font(.system(size: 24))
//                            Text(tab.rawValue)
//                                .font(.headline)
//                        }
//                        .padding()
//                        .foregroundColor(tab == selectedTab ? Color.white : Color.gray)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .background(tab == selectedTab ? Color.blue : Color.clear)
//                }
//            }
//            .background(Color.black)
//        }
//        .padding(.bottom, 2) // Add padding to the bottom of the VStack
//        .background(Color(red: 0.2, green: 0.2, blue: 0.2).edgesIgnoringSafeArea(.all))
//    }
//}
//
