import SwiftUI

struct TempoField: View {
    @FocusState private var isFocused: Bool
    @Binding var tempo: String
    
    var body: some View {
        HStack (spacing: 4){
            Text("[")
                .font(.title3)
            TextField("", text: $tempo)
                .keyboardType(.numberPad)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.blue)
                .focused($isFocused)
                .onChange(of: tempo) { _, newValue in
                    validateInput(newValue)
                }
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        validateInput(tempo)
                    }
                }
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
                .padding(.vertical, 12) // makes it more clickable
            Text("]")
                .font(.title3)
        }
    }
    
    
    func validateInput(_ newValue: String){
        let digits = newValue.filter { $0.isNumber }
        
        // 3 digits max
        if digits.count > 3 {
            tempo = String(digits.prefix(3))
            return
        }
        
        tempo = digits
        
        // if 3 digits, clamp to range [400, 460]
        if let num = Int(digits), digits.count == 3 {
            let clamped = min(max(num, 20), 240)
            tempo = String(clamped)
            return
        }
        
        // otherwise default to 400 (b/c that means the user deleted some numbers)
        if !isFocused {
            tempo = "120"
        }
    }
}
