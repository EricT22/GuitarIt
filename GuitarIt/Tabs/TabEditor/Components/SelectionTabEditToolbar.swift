import SwiftUI

struct SelectionTabEditToolbar: ToolbarContent {
    let selectedCount: Int
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    let onCancel: () -> Void
    
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            // Delete
            Button(action: {
                onDelete()
            }, label: {
                Image(systemName: "trash")
            })
            
            
            // Duplicate
            Button(action: {
                onDuplicate()
            }, label: {
                Image(systemName: "doc.on.doc")
            })
            
            // Cancel
            Button(action: {
                onCancel()
            }, label: {
                Image(systemName: "xmark")
            })
        }
    }
}
