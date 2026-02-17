import SwiftUI

struct OnOffSwitch: View {
    @Binding var isOn: Bool
    
    var body: some View {
        VStack {
            Text(isOn ? "On" : "Off")
                .font(.title2)
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
                .labelsHidden()
        }
        .padding()
    }
}
