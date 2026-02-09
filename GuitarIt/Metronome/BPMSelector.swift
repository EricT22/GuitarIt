import SwiftUI

struct BPMSelector: View {
    @Binding var bpm: Int
    var onChange: (() -> Void)? = nil
    
    
    var body: some View {
        Picker("BPM", selection: $bpm) {
            ForEach (1...500, id: \.self) { value in
                Text("\(value)")
            }
        }
        .pickerStyle(.wheel)
        .onChange(of: bpm) {
            onChange?()
        }
        .clipped()
    }
}
