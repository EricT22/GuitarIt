import SwiftUI

// View for the TabWriter section
struct TabWriterView: View {
    // Connects to the TabWriterViewModel
    @StateObject private var viewModel = TabWriterViewModel()
    
    var body: some View {
        // Centered description for the TabWriter page
        VStack {
            Spacer()
            Text("TabWriter")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
    }
}

#Preview {
    TabWriterView()
}
