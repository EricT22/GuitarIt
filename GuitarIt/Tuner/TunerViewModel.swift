import Foundation
import Combine

// ViewModel for the Tuner section
class TunerViewModel: ObservableObject {
    @Published var currentNote: String = "A"
    @Published var centsOffset: Double = 0.0
    @Published var tuningStandard: String = "440"
    @Published var isOn: Bool = false {
        didSet {
            handleToggle()
        }
    }
    
    private let audioCapture = AudioCapture()
    
    private let notes: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    init(){
        audioCapture.onPitch = {[weak self] pitch, confidence in
            guard confidence > 0.2 else { return }
            self?.updatePitch(frequency: Double(pitch))
        }
    }
    
    private func updatePitch(frequency f: Double){
        guard f > 0 else {
            // Pitch detection doesn't happen on main thread, happens on the AVAudioEngine callback
            // UI elements should be updated on the main thread
            DispatchQueue.main.async {
                self.currentNote = "A"
                self.centsOffset = 0.0
            }
            return
        }
        
        // Convert detected frequency to MIDI value (A4 @ tuning standard = 69)
        let a4 = Double(tuningStandard) ?? 440.0
        let midi = 69 + 12 * log2(f / a4)
        
        let midiRounded = Int(midi.rounded())
        
        // C-1 = 0, C0 = 12
        let index = midiRounded % 12
        let note = notes[index]
        
        // Finding target frequency based off of nearest Midi note
        let targetFrequency = a4 * pow(2.0, Double(midiRounded - 69) / 12.0)
        
        var cents = 1200 * log2(f / targetFrequency)
        cents = max(-50, min(50, cents))
            
        DispatchQueue.main.async {
            self.currentNote = note
            self.centsOffset = cents
        }
        
    }
    
    
    private func handleToggle() {
        if isOn {
            try? audioCapture.start()
        } else {
            audioCapture.stop()
            
            // Reset UI
            DispatchQueue.main.async {
                self.currentNote = "A"
                self.centsOffset = 0.0
            }
        }
    }
}
