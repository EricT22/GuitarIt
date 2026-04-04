import SwiftUI

struct TabEditView: View {
    @Binding var tab: TabItem
    
    @StateObject private var viewModel: TabEditViewModel
    @State private var isEditingTitle: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    @State private var selectionMode: Bool = false
    @State private var selectedGridIDs: Set<UUID> = []
    
    
    init(tab: Binding<TabItem>) {
        // _varname is the wrapper value... this is what has to be initialized so Swift can keep track of it
        self._tab = tab
        
        _viewModel = StateObject(wrappedValue: TabEditViewModel(tab: tab.wrappedValue))
    }
    
    
    private func toggleSelection(for id: UUID) {
        if selectedGridIDs.contains(id) {
            selectedGridIDs.remove(id)
        } else {
            selectedGridIDs.insert(id)
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    
    private func deleteSelectedGrids() {
        withAnimation(.easeInOut(duration: 0.25)) {
            viewModel.grids.removeAll { grid in
                selectedGridIDs.contains(grid.id)
            }
            selectedGridIDs.removeAll()
            selectionMode = false
        }
    }
    
    private func duplicateSelectedGrids() {
        withAnimation(.easeInOut(duration: 0.25)) {
            let indices = viewModel.grids.indices.filter { selectedGridIDs.contains(viewModel.grids[$0].id) }
            
            // Reversed so that inserting doesn't cause shifting errors
            for index in indices.sorted().reversed() {
                let copy = viewModel.grids[index].duplicate()
                
                viewModel.grids.insert(copy, at: index + 1)
            }
            
            // Selection mode still active but clears selected grids
            selectedGridIDs.removeAll()
        }
    }
    
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    ForEach($viewModel.grids) { $gridModel in
                        ZStack (alignment: .topLeading) {
                            
                            // Checkbox (selection only)
                            if (selectionMode) {
                                CheckBox(
                                    isSelected: selectedGridIDs.contains(gridModel.id),
                                    onTap: {
                                        toggleSelection(for: gridModel.id)
                                    }
                                )
                                .padding(8)
                                .transition(.scale.combined(with: .opacity))
                                .zIndex(2)
                            }
                            
                            if (!selectionMode) {
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation (.easeInOut(duration: 0.25)){
                                            dismissKeyboard()
                                            selectionMode = true
                                            selectedGridIDs = [gridModel.id]
                                        }
                                    }, label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(Color.secondary)
                                            .padding(12)
                                    })
                                }
                                .padding(.trailing, 4)
                                .padding(.top, -6)
                                .transition(.opacity)
                                .zIndex(3)
                            }

                            ZStack {
                                // Bounding box (selection only)
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectionMode ? Color.accentColor : Color.clear, lineWidth: 2)
                                    .animation(.easeInOut(duration: 0.25), value: selectionMode)
                                    .padding(4)
                                
                                
                                // Actual Grid
                                TabEditorGrid(model: $gridModel)
                                    .padding(8)
                                    .overlay(
                                        // Invisible lid blocking text fields but still lets taps in for selection
                                        selectionMode ?
                                            Color.clear
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                toggleSelection(for: gridModel.id)
                                            }
                                        : nil
                                    )
                            }
                            .zIndex(1)
                        }
                        .onTapGesture {
                            if (selectionMode) {
                                toggleSelection(for: gridModel.id)
                            }
                        }
                        .onLongPressGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                dismissKeyboard()
                                selectionMode = true
                                selectedGridIDs = [gridModel.id] // selecting the current, pressed grid
                            }
                        }
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
            if (selectionMode) {
                SelectionTabEditToolbar(
                    selectedCount: selectedGridIDs.count,
                    onDelete: {
                        showDeleteConfirmation = true
                    },
                    onDuplicate: {
                        duplicateSelectedGrids()
                    },
                    onCancel: {
                        withAnimation {
                            selectionMode = false
                            selectedGridIDs.removeAll()
                        }
                    }
                )
            } else {
                NormalTabEditToolbar(
                    isEditingTitle: $isEditingTitle,
                    tabName: $tab.name,
                    displayName: tab.displayName,
                    onAddGrid: { viewModel.appendGridFromTemplate()}
                )
            }
        }
        .confirmationDialog(
            "Delete \(selectedGridIDs.count) grid\(selectedGridIDs.count == 1 ? "" : "s")",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive){
                deleteSelectedGrids()
            }
            Button("Cancel", role: .cancel) {}
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
