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
    
    @State private var tabs: [TabItem] = [];
    
    
    private var sortedTabs: [TabItem] {
        switch sortMode {
        case .favoritesFirst:
                return tabs.sorted { // returns true if $0 should come before $1 (aka if left should go before right)
                    if ($0.isFavorite != $1.isFavorite) {
                        return $0.isFavorite && !$1.isFavorite
                    }
                    return $0.lastUsed > $1.lastUsed
                }
        case .lastUsed:
            return tabs.sorted { $0.lastUsed > $1.lastUsed }
        case .byDate:
            return tabs.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    
    
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
                    if (tabs.isEmpty){
                        Text("No tabs yet")
                            .foregroundStyle(Color.secondary)
                    } else {
                        ForEach(sortedTabs) { tab in
                            if let index = tabs.firstIndex(where: { $0.id == tab.id }){
                                TabRow(tab: $tabs[index])
                            }
                        }
                        .onDelete(perform: { indexSet in
                            tabs.remove(atOffsets: indexSet)
                        })
                    }
                }
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, .constant( isEditing ? .active : .inactive))
                
                Spacer()
                Button(
                    action: {
                        tabs.append(TabItem(name: ""))
                        
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
