import SwiftUI

// View for the Tuner section
struct TunerView: View {
    // Connects to the TunerViewModel
    @StateObject private var viewModel = TunerViewModel()
    @State private var color: Color = .white
    
    
    struct TunerState: Equatable {
        var note: String
        var cents: Double
    }
    
    
    var body: some View {
        ZStack{
            Color.clear
                .contentShape(Rectangle()) // makes whole screen tappable
                .onTapGesture { _ in
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil)
                } // gets rid of keyboard if its there
            VStack {
                Spacer()
                Text(viewModel.currentNote)
                    .font(.system(size: 200))
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Text("\(viewModel.centsOffset, specifier: "%.1f") cents")
                    .font(.largeTitle)
                    .foregroundStyle(color)
                Spacer()
                HStack {
                    OnOffSwitch(isOn: $viewModel.isOn)
                    TuningStandard(aVal: $viewModel.tuningStandard)
                }
            }
            .onChange(of: TunerState(note: viewModel.currentNote, cents: viewModel.centsOffset)) { old, new in
                if (viewModel.isOn) {
                    if (abs(new.cents) > 20.0){
                        color = .red
                    } else if (abs(new.cents) > 2.0) {
                        color = .yellow
                    } else {
                        color = .green
                    }
                } else {
                    color = .white
                }
            }
        }
    }
}


#Preview {
    TunerView()
}
