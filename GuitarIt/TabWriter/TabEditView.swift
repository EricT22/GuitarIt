import SwiftUI

struct TabEditView: View {
//    let tab: TabItem
    
    @State private var isEditingTitle: Bool = false
    
    @State private var name: String = "Untitled Tab"
    @State private var content: String = """
            
            e|------------------------------
            B|------------------------------
            G|------------------------------
            D|------------------------------
            A|------------------------------
            E|------------------------------

            """
    
    var body: some View {
        VStack {
            TextEditor(text: $content)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal)
                .scrollContentBackground(.hidden)
                .frame(maxHeight: .infinity)
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                if (isEditingTitle) {
                    isEditingTitle = false
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    isEditingTitle = false
                }, label: {
                    Image(systemName: "chevron.left")
                })
            }
            
            ToolbarItem(placement: .principal) {
                if (isEditingTitle) {
                    TextField("Name", text: $name, onCommit: {
                        isEditingTitle = false
                    })
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
                } else {
                    //Text(tab.displayName)
                    Text(name)
                        .font(.headline)
                        .onTapGesture {
                            isEditingTitle = true
                        }
                }
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    isEditingTitle = false
                }, label: {
                    Image(systemName: "square.grid.2x2")
                })

                Button(action: {
                    isEditingTitle = false
                }, label: {
                    Image(systemName: "square.and.arrow.down")
                })
            }
        }
        .onAppear {
            // stuff
        }
    }
}


#Preview {
    NavigationStack {
        TabEditView()
    }
}
