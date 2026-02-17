import Foundation
import Combine

// ViewModel for the Tuner section
class TunerViewModel: ObservableObject {
    @Published var isOn: Bool = false
    @Published var tuningStandard: String = "440"
}
