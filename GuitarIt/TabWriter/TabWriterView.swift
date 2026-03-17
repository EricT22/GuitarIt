import SwiftUI

// View for the TabWriter section
struct TabWriterView: View {
    // Connects to the TabWriterViewModel
    @StateObject private var viewModel = TabWriterViewModel()
    
    // Persisting Values
    // Can store raw value in UserDefaults by using the key "storageOption"
    @AppStorage("storageOption") private var storageOption: StorageOption = .local
    
    // No raw value for this enum, saving index instead in UserDefaults by using the key "sortMode"
    @AppStorage("sortMode") private var sortMode: SortMode = .favoritesFirst
    
    // UI State
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
                    let sortedTabs = viewModel.sortedTabs(sortMode: sortMode)
                    
                    if (sortedTabs.isEmpty){
                        Text("No tabs yet")
                            .foregroundStyle(Color.secondary)
                    } else {
                        ForEach(sortedTabs) { tab in
                            if let index = viewModel.tabs.firstIndex(where: { $0.id == tab.id }){
                                TabRow(tab: $viewModel.tabs[index])
                            }
                        }
                        .onDelete(perform: { indexSet in
                            viewModel.tabs.remove(atOffsets: indexSet)
                        })
                    }
                }
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, .constant( isEditing ? .active : .inactive))
                
                Spacer()
                Button(
                    action: {
                        viewModel.createNewTab(storage: storageOption)
                        
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
            SettingsView(storageOption: $storageOption, sortMode: $sortMode)
                .presentationDetents([.height(300)])
        })
    }
}

#Preview {
    TabWriterView()
}
