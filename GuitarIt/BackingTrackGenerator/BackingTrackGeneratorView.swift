import SwiftUI

// View for the BackingTrackGenerator section
struct BackingTrackGeneratorView: View {
    // Connects to the BackingTrackGeneratorViewModel
    @StateObject private var viewModel = BackingTrackGeneratorViewModel()
    
    private let twoColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle()) // makes whole screen tappable
                .onTapGesture { _ in
                    dismissKeyboard()
                }
            VStack {
                VStack {
                    Text("Backing Tracks")
                        .font(.largeTitle)
                        .bold()
                        .padding(2)
                }
                
                Spacer()
                
                HStack {
                    Text("Genre")
                        .font(.title)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                    Spacer()
                }
                Picker("Genre", selection: $viewModel.selectedGenre) {
                    ForEach(viewModel.genres, id: \.self) { genre in
                        Text(genre).tag(genre)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                
                HStack {
                    Text("Vibe")
                        .font(.title)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                    Spacer()
                }
                
                LazyVGrid(columns: twoColumns, spacing: 12) {
                    ForEach(viewModel.vibes, id: \.self) { vibe in
                        Button(action: {
                            dismissKeyboard()
                            viewModel.selectedVibe = vibe
                        }, label: {
                            Text(vibe)
                        })
                        .buttonStyle(SelectableButtonStyle(isSelected: viewModel.selectedVibe == vibe))
                    }
                }
                .padding(.horizontal, 5)
                
                Spacer()
                
                HStack {
                    Text("Instruments")
                        .font(.title)
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                    Spacer()
                }
                
                LazyVGrid(columns: twoColumns, spacing: 12) {
                    ForEach(viewModel.instruments, id: \.self) { instrument in
                        Button(action: {
                            dismissKeyboard()
                            viewModel.toggleInstrument(instrument)
                        }, label: {
                            Text(instrument)
                        })
                        .buttonStyle(SelectableButtonStyle(isSelected: viewModel.selectedInstruments.contains(instrument)))
                    }
                }
                .padding(.horizontal, 5)
                
                Spacer()
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
                
                
                Spacer()
                // Should have bounding box that extends to the edge of the screen
                // Once clicked, loading bar should appear for 1 sec
                // Replaced by new buttons
                // HStack with a play button and a REGENERATE Button (regenerate works the same as the generate button)
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                    } else if viewModel.hasGeneratedTrack {
                        HStack {
                            Button(action: {
                                viewModel.toggleTrack()
                            }, label: {
                                Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                                    .font(.system(size: 50))
                                    .frame(height: 44)
                            })
                            .buttonStyle(SelectableButtonStyle(isSelected: false))
                            .padding(.horizontal, 5)
                            
                            
                            Button(action: {
                                viewModel.generateWithAnimation()
                            }, label: {
                                Text("REMAKE")
                                    .font(.title)
                                    .frame(height:44)
                            })
                            .buttonStyle(SelectableButtonStyle(isSelected: viewModel.isGeneratePressed))
                            .padding(.horizontal, 5)
                        }
                    } else {
                        Button(action: {
                            viewModel.generateWithAnimation()
                        }, label: {
                            Text("GENERATE")
                                .font(.largeTitle)
                        })
                        .buttonStyle(SelectableButtonStyle(isSelected: viewModel.isGeneratePressed))
                        .padding(.horizontal, 5)
                    }
                }
                .animation(.easeInOut, value: viewModel.isLoading)
                .animation(.easeInOut, value: viewModel.hasGeneratedTrack)
                
                Spacer()
            }
        }
    }
}


#Preview {
    BackingTrackGeneratorView()
}
