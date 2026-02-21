import AVFoundation
import CoreML

class AudioCapture {
    private var audioEngine = AVAudioEngine()
    private var crepe = Crepe()
    
    
    func start() throws {
        let input = audioEngine.inputNode
        let format = input.inputFormat(forBus: 0) // mic runs at 48kHz, not what crepe needs but can't resampe here
        
        input.installTap(onBus: 0, bufferSize: 1024, format: format) {buffer, _ in
            self.handleAudio(buffer: buffer) // buffers filled with audio data @ intervals of 100ms
        }
        
        try audioEngine.start()
        print("started")
        
    }
    
    func stop(){
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        print("stopped")
    }
    
    private func handleAudio(buffer: AVAudioPCMBuffer) {
        guard let monoChannelData = buffer.floatChannelData?[0] else { return } // gets data from the first channel (makes it mono)
        let frameCount = Int(buffer.frameLength)
        
        // converts buffer pointer to Swift array
        let samples = Array(UnsafeBufferPointer(start: monoChannelData, count: frameCount))
        
        var downsampled = [Float]()
        downsampled.reserveCapacity(samples.count / 3)
        
        for i in stride(from: 0, to: samples.count, by: 3){
            downsampled.append(samples[i])
        }
        
        if downsampled.count >= 1024 {
            // Getting the 1024 samples for crepe
            let frame = Array(downsampled[0..<1024])
            
            if let result = crepe.predict(from: frame){
                let pitch = result.pitch
                let confidence = result.confidence
                
                print("Pitch: \(pitch), Confidence: \(confidence)")
            }
        }
    }
}
