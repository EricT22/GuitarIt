import SwiftUI

struct NormalTabEditToolbar: ToolbarContent {
    @Binding var isEditingTitle: Bool
    @Binding var tabName: String
    
    let displayName: String
    let onAddGrid: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if (isEditingTitle) {
                TextField("Name", text: $tabName, onCommit: {
                    isEditingTitle = false
                })
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            } else {
                Text(displayName)
                    .font(.headline)
                    .onTapGesture {
                        isEditingTitle = true
                    }
            }
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            // Templates Button
            Button(action: {
                isEditingTitle = false
            }, label: {
                Image(systemName: "square.grid.2x2")
            })

            // Add new template Button
            Button(action: {
                isEditingTitle = false
                
                withAnimation(.easeInOut(duration: (0.25))){
                    onAddGrid()
                }
            }, label: {
                Image(systemName: "plus")
            })
        }
    }
}
