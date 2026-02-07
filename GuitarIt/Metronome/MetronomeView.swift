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
            Text("BPM")
                .font(.title3)
            BPMSelector(bpm: $viewModel.bpm)
            Spacer()
            Button(
                action: {
                    // functionality
                    viewModel.startStop()
                }, label: {
                    Image(systemName: viewModel.isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 40))
                        .frame(width: 50, height: 50)
                })
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
            
            Spacer()
            
        }
    }
}


#Preview {
    MetronomeView()
}
