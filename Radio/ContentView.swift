
import SwiftUI
import WebKit
import AVFoundation

struct ContentView: View {
    @State private var selectedRadioStation = "Radio Paradise (RP)"
    @State private var webViewURL: URL?
    @State private var avPlayer: AVPlayer?
    @State private var volume: Float = 0.5 // Adjust this value as needed
    
    var radioStations: [String: String] = [
        "9128 Live": "https://9128.live",
        "Ambient Sleeping Pill": "https://ambientsleepingpill.com",
        "Bluemars": "http://echoesofbluemars.org",
        "dublab": "https://www.dublab.com",
        "FIP": "https://www.fip.fr",
        "FRISKY": "https://www.friskyradio.com",
        "(NASA) Third Rock Radio": "https://thirdrockradio.net",
        "NTS Radio": "https://www.nts.live",
        "Nightwave Plaza": "https://plaza.one",
        "Poolsuite FM": "https://poolsuite.net",
        "Radio Paradise (RP)": "https://radioparadise.com",
        "Shonen Beach FM": "https://www.beachfm.co.jp",
        "somafm": "https://somafm.com/",
        "Subcity Radio": "https://subcity.org",
        "BBC Radio 1": "http://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_one.m3u8",
        "BBC Radio 2": "http://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_two.m3u8",
        "BBC Radio 6": "http://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_6music.m3u8",
        "Indian1": "https://pub0101.101.ru:8000/stream/pro/aac/64/241?",
        "Indian2": "https://streaming.radio.co/s3aaa20a5e/listen",
        "Indian3": "https://16963.live.streamtheworld.com/SAM08AAC013_SC",
        "New Zealand1": "https://streamer.radio.co/s81fc850fd/listen",
        "New Zealand2": "https://s8.myradiostream.com/:58408/",
        "New Zealand3": "https://stream.radio.co/s2562b6e3a/listen",
        "New Zealand4": "https://chz.radioca.st/streams/128kbps",
        "New Zealand5": "https://live.accessmedia.nz/Coast.stream_aac/chunklist_w87842051.m3u8",
        "New Zealand6": "https://livestream.mediaworks.nz/radio_origin/more_128kbps/chunklist.m3u8",
        "New Zealand7": "https://live.accessmedia.nz/Fresh.stream_aac/chunklist_w107596192.m3u8",
        "New Zealand8": "https://ais-nzme.streamguys1.com/nz_046_aac",
        "New Zealand9": "https://cp12.serverse.com/proxy/hummfm?mp=/live",
        "New Zealand10": "https://c24.radioboss.fm:18080/stream",
        "New Zealand11": "https://centova.radioservers.biz/proxy/sleeprad/?mp=/stream&amp1589354343122"      ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Live Internet Radio")
                    .font(.largeTitle)
                    .foregroundColor(Color.blue)
                
                Picker("Radio Station", selection: $selectedRadioStation) {
                    ForEach(radioStations.keys.sorted(), id: \.self) { radioStation in
                        Text(radioStation)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Button(action: {
                    if let url = URL(string: radioStations[selectedRadioStation]!) {
                        webViewURL = url
                        let player = AVPlayer(url: url)
                        self.avPlayer = player
                        player.play()
                    }
                }) {
                    Text("Play")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Slider(value: $volume, in: 0...1) {
                    Text("Frequency: \(volume, specifier: "%.2f") MHz")
                        .foregroundColor(Color.blue)
                }
                .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        avPlayer?.pause()
                    }) {
                        Text("Pause")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        avPlayer?.replaceCurrentItem(with: nil)
                        webViewURL = nil
                    }) {
                        Text("Stop")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                if let url = webViewURL {
                    WebView(url: url)
                        .navigationBarTitle(selectedRadioStation, displayMode: .inline)
                }
            }
            .padding()
            .navigationBarTitle("Radio Stations")
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

