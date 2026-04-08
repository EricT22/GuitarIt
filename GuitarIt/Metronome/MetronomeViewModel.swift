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
    private var timer: DispatchSourceTimer? = nil
    
    func startStop() {
        started.toggle()
        
        if (started) {
            playMetronome()
        } else {
            stopMetronome()
        }
    }
    
    func stopMetronome() {
        timer?.cancel() // stops from running and removes requests from "run loop"
        timer = nil // throws the timer away
    }

    func playMetronome() {
        stopMetronome() // just in case
        
        let interval = 60.0 / Double(bpm)
        
        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .userInitiated))
        timer.schedule(deadline: .now(), repeating: interval)
        timer.setEventHandler { [weak self] in
            self?.metronome.click()
        }
        timer.resume()
        
        self.timer = timer
    }
    
    func onChange(){
        if (started) {
            startStop()
        }
    }
}
