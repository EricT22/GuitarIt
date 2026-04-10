import SwiftUI

struct SelectableButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : Color.clear)
            .foregroundStyle(isSelected ? Color(.systemBackground) : Color.accentColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.accentColor, lineWidth: 1.5)
            )
            .clipShape(.rect(cornerRadius: 12))
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
