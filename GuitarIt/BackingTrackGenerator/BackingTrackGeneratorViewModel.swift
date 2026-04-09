import Foundation
import Combine

// ViewModel for the BackingTrackGenerator section
class BackingTrackGeneratorViewModel: ObservableObject {
    
    @Published var tempo: String = "120"
    
    
    @Published var beatCount: String = "4"
    @Published var beatUnit: String = "4"
}
