import SwiftUI

// View for the BackingTrackGenerator section
struct BackingTrackGeneratorView: View {
    // Connects to the BackingTrackGeneratorViewModel
    @StateObject private var viewModel = BackingTrackGeneratorViewModel()
    
    var body: some View {
        // Centered description for the BackingTrackGenerator page
        VStack {
            Text("Backing Tracks")
                .font(.largeTitle)
                .bold()
                .padding(2)
        }
        
        HStack {
            Text("Genre")
                .font(.title)
                .padding(.horizontal)
                .padding(.vertical, 3)
            Spacer()
            // Drop down element with different genres
            // Ex. rock, blues, punk, metal, etc.
        }
        
        HStack {
            Text("Vibe")
                .font(.title)
                .padding(.horizontal)
                .padding(.vertical, 3)
            Spacer()
        }
        
        // Block of four buttons (2x2 grid)
        // That have keywords that can be used to specify the
        // vibe of the genre

        HStack {
            Text("Instruments")
                .font(.title)
                .padding(.horizontal)
                .padding(.vertical, 3)
            Spacer()
        }
        
        // Block of four buttons (2x2 grid)
        // That have have instrument names as labels that can be used to specify the
        // instruments being played based on the genre & vibe
        
        HStack {
            Text("Signature")
                .font(.title3)
                .padding(.leading, -5)
                .padding(.trailing, 5)
                .padding(.vertical, 3)
            
            TimeSignatureField(beatCount: $viewModel.beatCount, beatUnit: $viewModel.beatUnit)
            
            Text("|")
                .font(.title3)
                .padding(.leading, 18)
                .padding(.trailing, 20)
                .padding(.vertical, 3)
            
            
            Text("Tempo")
                .font(.title3)
                .padding(.leading, -5)
                .padding(.trailing, 1)
                .padding(.vertical, 3)
            
            TempoField(tempo: $viewModel.tempo)
        }
        
        // Should have bounding box that extends to the edge of the screen
        // Once clicked, loading bar should appear for 1 sec
        // Replaced by new buttons
        // HStack with a play button and a REGENERATE Button (regenerate works the same as the generate button)
        Button(action: {
            
        }, label: {
            Text("GENERATE")
                .font(.largeTitle)
        })
        
    }
}


#Preview {
    BackingTrackGeneratorView()
}
