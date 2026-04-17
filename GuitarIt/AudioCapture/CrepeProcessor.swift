import Foundation

class CrepeProcessor {
    private let crepe = Crepe()
    
    private var downsampledBuffer: [Float] = []
    
    var onPitchPredict: ((Float, Float) -> Void)?
    
    // incoming audio @48kHz
    func process(samples: [Float]) {
        // Crepe requires audio at 16khz, downsampling required
        
        for i in stride(from: 0, to: samples.count, by: 3){
            downsampledBuffer.append(samples[i])
        }
        
        while downsampledBuffer.count >= 1024 {
            // Getting the 1024 samples for crepe
            let frame = Array(downsampledBuffer[0..<1024])
            downsampledBuffer.removeFirst(1024)
            
            if let result = crepe.predict(from: frame){
                let pitch = result.pitch
                let confidence = result.confidence
                
                print("Pitch: \(pitch), Confidence: \(confidence)")
                onPitchPredict?(pitch, confidence)
            }
        }
    }
}
