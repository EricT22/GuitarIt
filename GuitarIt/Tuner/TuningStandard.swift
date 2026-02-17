import SwiftUI

struct TuningStandard: View {
    @FocusState private var isFocused: Bool
    @Binding var aVal: String
    
    
    var body: some View {
        HStack (spacing: 4){
            Text("[")
                .font(.title3)
            TextField("", text: $aVal)
                .keyboardType(.numberPad)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.blue)
                .focused($isFocused)
                .onChange(of: aVal) { _, newValue in
                    validateInput(newValue)
                }
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        validateInput(aVal)
                    }
                }
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
                .padding(.vertical, 12) // makes it more clickable
            Text("] Hz")
                .font(.title3)
        }
        .padding()
    }
    
    
    func validateInput(_ newValue: String){
        let digits = newValue.filter { $0.isNumber }
        
        // 3 digits max
        if digits.count > 3 {
            aVal = String(digits.prefix(3))
            return
        }
        
        aVal = digits
        
        // if 3 digits, clamp to range [400, 460]
        if let num = Int(digits), digits.count == 3 {
            let clamped = min(max(num, 400), 460)
            aVal = String(clamped)
            return
        }
        
        // otherwise default to 400 (b/c that means the user deleted some numbers)
        if !isFocused {
            aVal = "400"
        }
    }

}


