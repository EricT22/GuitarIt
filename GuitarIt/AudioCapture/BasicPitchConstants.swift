struct BasicPitchConstants {
    static let fftHop = 256
    static let sampleRate = 22050
    static let windowLengthSeconds = 2
    
    // Windowing
    static let framesPerWindow = 172 // ANNOT_N_FRAMES
    static let overlapFrames = 30
    
    // MIDI
    static let midiOffset = 21
    
    
    // Derived
    static let audioNSamples = sampleRate * windowLengthSeconds - fftHop
    static let windowSize = audioNSamples // 43844
    
    // Post processing
    static let magicAlignmentOffset = 0.0018
    static let energyTolerance = 11
    static let minNoteLengthFrames = 11
}
