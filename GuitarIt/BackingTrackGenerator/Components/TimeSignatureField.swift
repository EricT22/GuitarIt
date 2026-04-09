import SwiftUI

struct TimeSignatureField: View {
    @Binding var beatCount: String // Top number
    @Binding var beatUnit: String // Bottom number
    
    @FocusState private var isTopFocused: Bool
    @FocusState private var isBottomFocused: Bool
    
    var body: some View {
        HStack {
            // Count
            TextField("", text: $beatCount)
                .keyboardType(.numberPad)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.blue)
                .focused($isTopFocused)
                .onChange(of: beatCount) { _, newValue in
                    validateTop(newValue)
                }
                .onChange(of: isTopFocused) { _, focused in
                    if !focused {
                        validateTop(beatCount)
                    }
                }
                .frame(width: 12, height: 40)
                .contentShape(Rectangle())
            
            Text("/")
                .font(.title3)
            
            // Unit
            TextField("", text: $beatUnit)
                .keyboardType(.numberPad)
                .font(.title3)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.blue)
                .focused($isBottomFocused)
                .onChange(of: beatUnit) { _, newValue in
                    validateBottom(beatUnit)
                }
                .onChange(of: isBottomFocused) { _, focused in
                    if !focused {
                        validateBottom(beatUnit)
                    }
                }
                .frame(width: 24, height: 40)
                .contentShape(Rectangle())
        }
    }
    
    private func validateTop(_ newValue: String) {
        let digits = newValue.filter { $0.isNumber }
        
        if digits.count > 1 {
            beatCount = String(digits.prefix(1))
            return
        }
        
        beatCount = digits
        
        if let num = Int(digits), digits.count == 1 {
            let clamped = min(max(num, 1), 9)
            beatCount = String(clamped)
            return
        }
        
        if !isTopFocused {
            beatCount = "4"
        }
    }
    
    
    private func validateBottom(_ newValue: String) {
        let digits = newValue.filter { $0.isNumber }
        
        if digits.count > 2 {
            beatUnit = String(digits.prefix(2))
            return
        }
        
        beatUnit = digits
        
        if let num = Int(digits) {
            
            if digits.count == 2 {
                let clamped = min(max(num, 10), 32)
                beatUnit = String(clamped)
                return
            } else if digits.count == 1 {
                let clamped = min(max(num, 1), 9)
                beatUnit = String(clamped)
                return
            }
        }
        
        if !isBottomFocused {
            beatUnit = "4"
        }
    }
}
