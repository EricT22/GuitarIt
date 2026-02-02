import SwiftUI

// View for the BackingTrackGenerator section
struct BackingTrackGeneratorView: View {
    // Connects to the BackingTrackGeneratorViewModel
    @StateObject private var viewModel = BackingTrackGeneratorViewModel()
    
    var body: some View {
        // Centered description for the BackingTrackGenerator page
        VStack {
            Spacer()
            Text("BackingTrackGenerator")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
    }
}


#Preview {
    BackingTrackGeneratorView()
}
