import Foundation
import Combine

// ViewModel for the Tuner section
class TunerViewModel: ObservableObject {
    @Published var tuningStandard: String = "440"
    @Published var isOn: Bool = false {
        didSet {
            handleToggle()
        }
    }
    
    private let audioCapture = AudioCapture()
    
    private func handleToggle() {
        if isOn {
            try? audioCapture.start()
        } else {
            audioCapture.stop()
        }
    }
}
