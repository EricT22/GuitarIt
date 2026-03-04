import SwiftUI

// View for the TabWriter section
struct TabWriterView: View {
    // Connects to the TabWriterViewModel
    @StateObject private var viewModel = TabWriterViewModel()
    
    @State private var storageSetting: StorageOption = .local
    @State private var showSettings: Bool = false
    @State private var isEditing: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        isEditing.toggle()
                    }, label: {
                        Text(isEditing ? "Done" : "Edit")
                            .font(.system(size: 20))
                    })
                    Spacer()
                    Button(action: {
                        showSettings = true
                    }, label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                    })
                }
                .padding(.horizontal)
                Text("Tab Writer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                List {
                    Text("No tabs yet")
                        .foregroundStyle(Color.secondary)
                    Text("No tabs yet")
                        .foregroundStyle(Color.secondary)
                    Text("No tabs yet")
                        .foregroundStyle(Color.secondary)
                    Text("No tabs yet")
                        .foregroundStyle(Color.secondary)
                    Text("No tabs yet")
                        .foregroundStyle(Color.secondary)
                    Text("No tabs yet")
                        .foregroundStyle(Color.secondary)
                }
                .scrollContentBackground(.hidden)
                Spacer()
                Button(
                    action: {
                        // functionality
                        
                    }, label: {
                        Image(systemName: "plus")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .frame(width: 50, height: 50)
                    })
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .padding()
            }
        }
        .sheet(isPresented: $showSettings, content: {
            StorageSettingsView(storageOption: $storageSetting)
                .presentationDetents([.height(200)])
        })
    }

    
    
}

#Preview {
    TabWriterView()
}
