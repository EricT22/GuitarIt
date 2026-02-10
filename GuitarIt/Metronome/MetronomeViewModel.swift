// click.wav sound by:

// Metronome.wav by Druminfected --
// https://freesound.org/s/250552/ --
// License: Creative Commons 0


import Foundation
import Combine

// ViewModel for the Metronome section
class MetronomeViewModel: ObservableObject {
    // default metronome bpm
    @Published var bpm: Int = 120;
    @Published var started: Bool = false;
    
    private let metronome = Metronome()
    private var timer: Timer? = nil
    
    func startStop() {
        started.toggle()
        
        if (started) {
            playMetronome()
        } else {
            stopMetronome()
        }
    }
    
    func stopMetronome() {
        timer?.invalidate() // stops from running and removes requests from "run loop"
        timer = nil // throws the timer away
    }

    func playMetronome() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(bpm), repeats: true) {_ in
            self.metronome.click()
        }
    }
    
    func onChange(){
        if (started) {
            startStop()
        }
    }
}
