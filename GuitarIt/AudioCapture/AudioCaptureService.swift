import AVFoundation


final class AudioCaptureService {
    static let shared = AudioCaptureService()
    
    private let audioCapture = AudioCapture()
    private var activeConsumers: Int = 0
    
    // Broadcast to all listeners
    private var listeners: [UUID : ([Float]) -> Void] = [:]
    
    private init() {
        audioCapture.onAudioSamples = { [weak self] samples in
            guard let self = self else { return }
            
            for (_, listener) in self.listeners {
                listener(samples)
            }
        }
    }
    
    @discardableResult // Tells compiler that the result can be ignored
    func addListener(_ listener: @escaping ([Float]) -> Void) -> UUID { // @escaping = closure stored and used outside of the func call
        let id = UUID()
        listeners[id] = listener
        
        return id
    }
    
    func removeListener(_ id: UUID) {
        listeners.removeValue(forKey: id)
    }
    
    func startIfNeeded() {
        activeConsumers += 1
        
        if (activeConsumers == 1) {
            try? audioCapture.start()
        }
    }
    
    func stopIfPossible() {
        activeConsumers = max(0, activeConsumers - 1)
        
        if (activeConsumers == 0) {
            audioCapture.stop()
        }
    }
}
