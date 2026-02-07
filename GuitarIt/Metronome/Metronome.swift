import AVFoundation

class Metronome {
    private var player: AVAudioPlayer?
    
    func click() {
        if (player == nil){
            let url = Bundle.main.url(forResource: "click", withExtension:".wav")! // exclaimation basically forces app to find url or crash
            player = try? AVAudioPlayer(contentsOf: url)
        }
        
        // Sets play point to the beginning of audio file
        player?.currentTime = 0
        // Preps audio buffers and reduces latency (supposedly)
        player?.prepareToPlay()
        player?.play()
    }
}
