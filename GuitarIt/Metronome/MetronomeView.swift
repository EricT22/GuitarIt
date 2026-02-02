import SwiftUI

// View for the Metronome section
struct MetronomeView: View {
    // Connects to the MetronomeViewModel
    @StateObject private var viewModel = MetronomeViewModel()
    
    var body: some View {
        // Centered description for the Metronome page
        VStack {
            Spacer()
            Text("Metronome")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
    }
}


#Preview {
    MetronomeView()
}
