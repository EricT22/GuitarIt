import SwiftUI

struct TabEditView: View {
    @Binding var tab: TabItem
    
    @StateObject private var viewModel: TabEditViewModel
    
    @State private var isEditingTitle: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    
    
    init(tab: Binding<TabItem>) {
        // _varname is the wrapper value... this is what has to be initialized so Swift can keep track of it
        self._tab = tab
        
        _viewModel = StateObject(wrappedValue: TabEditViewModel(tab: tab.wrappedValue))
    }
    
    
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    ForEach($viewModel.grids) { $gridModel in
                        GridCellView(
                            gridModel: $gridModel,
                            viewModel: viewModel,
                            dismissKeyboard: dismissKeyboard
                        )
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.15), value: viewModel.grids)
            }
            .coordinateSpace(.named("scrollView"))
        }
        .onPreferenceChange(GridCellFramePreferenceKey.self) { frames in
            viewModel.gridFrames = frames
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
            if (viewModel.selectionMode) {
                SelectionTabEditToolbar(
                    selectedCount: viewModel.selectedGridIDs.count,
                    onDelete: {
                        showDeleteConfirmation = true
                    },
                    onDuplicate: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.duplicateSelectedGrids()
                        }
                    },
                    onCancel: {
                        withAnimation {
                            viewModel.selectionMode = false
                            viewModel.selectedGridIDs.removeAll()
                        }
                    }
                )
            } else {
                NormalTabEditToolbar(
                    isEditingTitle: $isEditingTitle,
                    tabName: $tab.name,
                    displayName: tab.displayName,
                    onAddGrid: { viewModel.appendGridFromTemplate() }
                )
            }
        }
        .confirmationDialog(
            "Delete \(viewModel.selectedGridIDs.count) grid\(viewModel.selectedGridIDs.count == 1 ? "" : "s")",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive){
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.deleteSelectedGrids()
                }
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
