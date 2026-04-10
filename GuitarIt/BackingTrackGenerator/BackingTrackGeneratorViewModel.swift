import Foundation
import Combine
import AVFoundation

// ViewModel for the BackingTrackGenerator section
class BackingTrackGeneratorViewModel: ObservableObject {
    
    @Published var tempo: String = "120"
    
    @Published var beatCount: String = "4"
    @Published var beatUnit: String = "4"
    
    // Genres
    @Published var genres = ["Rock", "Blues", "Metal", "Punk", "Jazz", "Funk"]
    @Published var selectedGenre = "Rock" {
        didSet {
            if let newVibes = vibeOptionsByGenre[selectedGenre] {
                vibes = newVibes
                selectedVibe = newVibes.first ?? ""
            }
        }
    }
    
    // Vibe
    let vibeOptionsByGenre: [String: [String]] = [
        "Rock": ["Gritty", "Driving", "Anthemic", "Heavy"],
        "Blues": ["Soulful", "Groovy", "Raw", "Vintage"],
        "Metal": ["Aggressive", "Fast", "Epic", "Dark"],
        "Punk": ["Raw", "Fast", "Rebellious", "Chaotic"],
        "Jazz": ["Smooth", "Swing", "Late-Night", "Cool"],
        "Funk": ["Groovy", "Syncopated", "Punchy", "Warm"]
    ]
    @Published var vibes: [String] = []
    @Published var selectedVibe: String = ""
    
    // Instruments
    @Published var instruments = ["Guitar", "Bass", "Drums", "Keys"]
    @Published var selectedInstruments: Set<String> = ["Guitar", "Bass", "Drums"]
    
    // Generation State
    @Published var isLoading = false
    @Published var hasGeneratedTrack = false
    @Published var isGeneratePressed = false
    @Published var isPlaying = false
    
    
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    
    
    init() {
        if let initialVibes = vibeOptionsByGenre[selectedGenre] {
            vibes = initialVibes
            selectedVibe = initialVibes.first ?? ""
        }
        
        setupAudio()
    }
    
    
    private func setupAudio() {
        engine.attach(player)

        // Placeholder for a real backing track
        let url = Bundle.main.url(forResource: "click", withExtension: "wav")!
        audioFile = try? AVAudioFile(forReading: url)

        let format = audioFile!.processingFormat
        engine.connect(player, to: engine.mainMixerNode, format: format)

        try? engine.start()
    }
    
    
    
    func toggleInstrument(_ instrument: String) {
        if selectedInstruments.contains(instrument) {
            selectedInstruments.remove(instrument)
        } else {
            selectedInstruments.insert(instrument)
        }
    }
    
    func generateWithAnimation() {
        isGeneratePressed = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            self.isGeneratePressed = false
            self.generateTrack()
        }
    }
    
    func generateTrack() {
        isLoading = true
        hasGeneratedTrack = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.isLoading = false
            self.hasGeneratedTrack = true
        }
    }
    
    func toggleTrack() {
        isPlaying.toggle()
        
        if (isPlaying) {
            playTrack()
        } else {
            stopTrack()
        }
    }
    
    private func playTrack() {
        print("Playing generated track...")
        
        guard let audioFile = audioFile else { return }

        isPlaying = true

        // Stop any previous playback and reset
        player.stop()

        // Schedule from the beginning
        player.scheduleFile(audioFile, at: nil, completionHandler: loopTrack)

        player.play()
    }
    
    private func stopTrack() {
        print("Stopped playing track.")
        player.stop()
    }
    
    private func loopTrack() {
        if isPlaying {
            player.scheduleFile(audioFile!, at: nil, completionHandler: loopTrack)
        }
    }
}
