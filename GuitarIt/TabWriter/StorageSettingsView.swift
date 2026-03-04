import SwiftUI

enum StorageOption: String, CaseIterable {
    case local = "Local"
    case cloud = "iCloud"
}


struct StorageSettingsView: View {
    @Binding var storageOption: StorageOption
    
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
        }
    }
}
