import SwiftUI

// View for the Tuner section
struct TunerView: View {
    // Connects to the TunerViewModel
    @StateObject private var viewModel = TunerViewModel()
    
    var body: some View {
        // Centered description for the Tuner page
        VStack {
            Spacer()
            Text("Tuner")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
    }
}


#Preview {
    TunerView()
}
