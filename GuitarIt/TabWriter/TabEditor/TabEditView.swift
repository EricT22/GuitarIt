import SwiftUI

struct TabEditView: View {
    @Binding var tab: TabItem
    
    @StateObject private var viewModel: TabEditViewModel
    @State private var isEditingTitle: Bool = false
    
    
    init(tab: Binding<TabItem>) {
        // _varname is the wrapper value... this is what has to be initialized so Swift can keep track of it
        self._tab = tab
        
        _viewModel = StateObject(wrappedValue: TabEditViewModel(tab: tab.wrappedValue))
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    ForEach($viewModel.grids) { $gridModel in
                        TabEditorGrid(model: $gridModel)
                    }
                }
                .padding()
            }
        }
        .onChange(of: tab.name) {
            tab.name = sanitizeInput(tab.name)
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                if (isEditingTitle) {
                    isEditingTitle = false
                }
            }
        )
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                if (isEditingTitle) {
                    TextField("Name", text: $tab.name, onCommit: {
                        isEditingTitle = false
                    })
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                } else {
                    Text(tab.displayName)
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
                    
                    viewModel.appendGridFromTemplate()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .onAppear {
            viewModel.load()
        }
        .onDisappear() {
            viewModel.save()
        }
    }
}

//
//#Preview {
//    NavigationStack {
//        TabEditView()
//    }
//}
