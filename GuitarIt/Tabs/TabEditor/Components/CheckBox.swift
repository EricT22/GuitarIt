import SwiftUI

struct CheckBox: View {
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: 22, height: 22)
                .background(Color(.systemBackground))
                .clipShape(Circle())
            
            if (isSelected) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}
