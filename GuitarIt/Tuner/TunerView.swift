import SwiftUI

// View for the Tuner section
struct TunerView: View {
    // Connects to the TunerViewModel
    @StateObject private var viewModel = TunerViewModel()
    
    // TODO: make keyboard go away a function
    
    
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
                Text("A")
                    .font(.system(size: 200))
                    .fontWeight(.bold)
                Text("0 cents")
                    .font(.largeTitle)
                Spacer()
                HStack {
                    OnOffSwitch(isOn: $viewModel.isOn)
                    TuningStandard(aVal: $viewModel.tuningStandard)
                }
            }
        }
    }
}


#Preview {
    TunerView()
}
