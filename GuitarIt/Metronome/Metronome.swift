import AVFoundation

class Metronome {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var buffer: AVAudioPCMBuffer?
    
    init() {
        setup()
    }
    
    func setup() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        
        loadClick()
        
        do {
            try engine.start()
        } catch {
            print("Engine start error: \(error)")
        }
    }
    
    func loadClick() {
        let url = Bundle.main.url(forResource: "click", withExtension:".wav")! // exclaimation basically forces app to find url or crash
        
        let file = try! AVAudioFile(forReading: url)
        let monoFormat = file.processingFormat
        let frameCount = UInt32(file.length)
        
        // Mono file
        let monoBuffer = AVAudioPCMBuffer(pcmFormat: monoFormat, frameCapacity: frameCount)!
        try! file.read(into: monoBuffer)
        
        let stereoFormat = AVAudioFormat(commonFormat: monoFormat.commonFormat,
                                         sampleRate: monoFormat.sampleRate,
                                         channels: 2,
                                         interleaved: monoFormat.isInterleaved)!
        
        let stereoBuffer = AVAudioPCMBuffer(pcmFormat: stereoFormat, frameCapacity: frameCount)!
        
        // Making it stereo
        // Variablees are pointers
        let mono = monoBuffer.floatChannelData![0]
        let left = stereoBuffer.floatChannelData![0]
        let right = stereoBuffer.floatChannelData![1]
        
        for i in 0..<Int(frameCount) {
            left[i] = mono[i]
            right[i] = mono[i]
        }
        
        stereoBuffer.frameLength = frameCount
        
        self.buffer = stereoBuffer
    }
    
    
    func click() {
        guard let buffer = buffer else { return }
        
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        player.play()
    }
}
