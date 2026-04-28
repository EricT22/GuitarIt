import CoreML

class BasicPitchProcessor {
    private let basicPitch = BasicPitch()
    
    private var resampleBuffer: [Float] = []
    private var windowBuffer: [Float] = []
    private var windowOutputs: [Float] = []
    
    private let inputRate: Int = 48000
    private let targetRate: Int = 22050
    private let ratio: Float
    private var resampleAccumulator: Float = 0
    
    var onNotes: (([NoteEvent]) -> Void)?
    
    init() {
        self.ratio = Float(inputRate) / Float(targetRate)
    }
    
    func process(samples: [Float]) {
        // Fractional sampling (we need a 22050 kHz sample for Basic Pitch)
        for sample in samples {
            resampleAccumulator += 1.0
            
            if resampleAccumulator > ratio {
                resampleAccumulator -= ratio
                resampleBuffer.append(sample)
            }
        }
        
        // Rolling buffer
        windowBuffer.append(contentsOf: resampleBuffer)
        resampleBuffer.removeAll()
        
        // Get windows
        // size of input needed for Basic Pitch (called AUDIO_N_SAMPLES in Spotify's source code)
        let windowSize = BasicPitchConstants.windowSize
        // windowSize - overlapLen ; where overlapLen = DEFAULT_OVERLAPPING_FRAMES * fftHop aka (30 * 256)
        let hopSize = windowSize - (BasicPitchConstants.overlapFrames * BasicPitchConstants.fftHop)
        
        while windowBuffer.count >= windowSize {
            let window = Array(windowBuffer[0..<windowSize])
            windowBuffer.removeFirst(hopSize)
            
            // Model runs here
            let notes = basicPitch.processWindow(window)
            
            
            if !notes.isEmpty {
                onNotes?(notes)
            }
        }
    }
    
}
