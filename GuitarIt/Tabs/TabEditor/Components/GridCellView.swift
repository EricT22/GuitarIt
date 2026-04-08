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
//                    .gesture(
//                        LongPressGesture(minimumDuration: 0.25)
//                            .sequenced(before: DragGesture(minimumDistance: 0))
//                            .updating($dragOffset) { value, state, _ in
//                                // Vertical offset only
//                                if case .second(true, let drag?) = value {
//                                    state = drag.translation.height
//                                }
//                            }
//                            .onChanged { value in
//                                switch value {
//                                    // Long press completed, drag not started
//                                case .first(true):
//                                    viewModel.pressedGridID = gridModel.id
//                                    let block = viewModel.draggedBlock(for: gridModel.id)
//                                    viewModel.dragRange = block
//                                    
//                                    viewModel.activeDraggedIDs = Set(viewModel.idsForRange(block))
//                                    
//                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
//                                        viewModel.isReordering = true
//                                    }
//                                    
//                                    // Drag is happening
//                                case .second(true, let drag?):
//                                    let offset = drag.translation.height
//                                    viewModel.updateReorder(with: offset)
//                                    
//                                    break
//                                default:
//                                    break
//                                }
//                            }
//                            .onEnded { _ in
//                                // Reset drag state
//                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
//                                    viewModel.isReordering = false
//                                }
//                                viewModel.activeDraggedIDs.removeAll()
//                                viewModel.dragRange = nil
//                            }
//                    )
            }
            .zIndex(1)
        }
        .offset(y: viewModel.activeDraggedIDs.contains(gridModel.id) ? dragOffset : 0)
        .zIndex(viewModel.activeDraggedIDs.contains(gridModel.id) ? 1 : 0)
        .onTapGesture {
            if (viewModel.selectionMode) {
                viewModel.toggleSelection(for: gridModel.id)
            }
        }
//        .background(GeometryReader { geo in
//            Color.clear.preference(
//                key: GridCellFramePreferenceKey.self,
//                value: [gridModel.id: geo.frame(in: .named("scrollView"))]
//            )
//        })
    }
}
