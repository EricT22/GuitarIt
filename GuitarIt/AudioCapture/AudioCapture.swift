import AVFoundation

class AudioCapture {
    private var audioEngine = AVAudioEngine()
    
    var onAudioSamples: (([Float]) -> Void)?
    
    func start() throws {
        let input = audioEngine.inputNode
        let format = input.inputFormat(forBus: 0) // mic runs at 48kHz, resampling will happen elsewhere
        
        input.installTap(onBus: 0, bufferSize: 1024, format: format) {[weak self] buffer, _ in
            // buffers filled with audio data @ intervals of 100ms & broadcast
            
            guard let self = self else { return }
            guard let monoChannelData = buffer.floatChannelData?[0] else { return } // gets data from the first channel (makes it mono)
            
            let frameCount = Int(buffer.frameLength)
            
            // converts buffer pointer to Swift array
            let samples = Array(UnsafeBufferPointer(start: monoChannelData, count: frameCount))
            
            self.onAudioSamples?(samples)
        }
        
        try audioEngine.start()
        print("started")
        
    }
    
    func stop(){
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        print("stopped")
    }
    
}
