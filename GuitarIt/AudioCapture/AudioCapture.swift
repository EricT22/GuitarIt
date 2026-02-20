import AVFoundation


class AudioCapture {
    private var audioEngine = AVAudioEngine()
    
    func start() throws {
        let input = audioEngine.inputNode
        let format = input.inputFormat(forBus: 0) // mic runs at 48kHz, not what crepe needs but can't resampe here
        
        input.installTap(onBus: 0, bufferSize: 1024, format: format) {buffer, _ in
            self.handleAudio(buffer: buffer)
        }
        
        try audioEngine.start()
        print("started")
        
    }
    
    func handleAudio(buffer: AVAudioPCMBuffer) {
        print("Got buffer w/ \(buffer.frameLength) frames")
    }
}
