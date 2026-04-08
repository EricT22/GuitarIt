import SwiftUI

struct GridCellView: View {
    @Binding var gridModel: TabEditorModel
    @ObservedObject var viewModel: TabEditViewModel
    
    @GestureState private var dragOffset: CGFloat = 0
    
    let dismissKeyboard: () -> Void
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            
            // Checkbox (selection only)
            if (viewModel.selectionMode) {
                CheckBox(
                    isSelected: viewModel.selectedGridIDs.contains(gridModel.id),
                    onTap: {
                        viewModel.toggleSelection(for: gridModel.id)
                    }
                )
                .padding(8)
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
            
            if (!viewModel.selectionMode) {
                HStack {
                    Spacer()
                    
                    // Move up
                    Button(action: {
                        dismissKeyboard()
                        viewModel.moveGrid(gridModel.id, movingUpwards: true)
                    }, label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .padding(8)
                    })
                    
                    // Move down
                    Button(action: {
                        dismissKeyboard()
                        viewModel.moveGrid(gridModel.id, movingUpwards: false)
                    }, label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .padding(8)
                    })
                    
                    // Selection mode
                    Button(action: {
                        withAnimation (.easeInOut(duration: 0.25)){
                            dismissKeyboard()
                            viewModel.selectionMode = true
                            viewModel.selectedGridIDs = [gridModel.id]
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
                    .stroke(viewModel.selectionMode ? Color.accentColor : Color.clear, lineWidth: 2)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.selectionMode)
                    .padding(4)
                
                
                // Actual Grid
                TabEditorGrid(model: $gridModel)
                    .padding(8)
                    .overlay(
                        // Invisible lid blocking text fields but still lets taps in for selection
                        viewModel.selectionMode ?
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.toggleSelection(for: gridModel.id)
                            }
                        : nil
                    )
            }
            .zIndex(1)
        }
        .onTapGesture {
            if (viewModel.selectionMode) {
                viewModel.toggleSelection(for: gridModel.id)
            }
        }
    }
}


