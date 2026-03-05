import SwiftUI

enum StorageOption: String, CaseIterable {
    case local = "Local"
    case cloud = "iCloud"
}

enum SortMode {
    case favoritesFirst
    case byDate
    case lastUsed
}


struct SettingsView: View {
    @Binding var storageOption: StorageOption
    @Binding var sortMode: SortMode
    
    var body: some View {
        VStack {
            Text("Storage Preference:")
                .font(.headline)
                .padding()
            Picker("Storage", selection: $storageOption){
                ForEach(StorageOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Text("Sort Tabs:")
                .font(.headline)
                .padding()
            Picker("Sorting", selection: $sortMode){
                Text("Favorites First").tag(SortMode.favoritesFirst)
                Text("Last Used").tag(SortMode.lastUsed)
                Text("Date Created").tag(SortMode.byDate)
            }
            .pickerStyle(.segmented)
            .padding()
        }
    }
}
