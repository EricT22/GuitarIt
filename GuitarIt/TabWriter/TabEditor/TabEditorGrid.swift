import SwiftUI


struct TabEditorGrid: View {
    @Binding var model: TabEditorModel
    
    var numDashes: Int { model.grid.first?.count ?? 0 }
    var stringNames: [String] { model.stringNames }
    
    var stringNameColumnWidth: CGFloat {
        let longest = stringNames.map { ($0 + "|").count }.max() ?? 1
        return CGFloat(longest * 10 + 8)
    }
    
    
    var body: some View {
        VStack (spacing: 6) {
            ForEach(0..<stringNames.count, id: \.self) { row in
                HStack (spacing: 3){
                    Text("\(stringNames[row])|")
                        .font(.system(.body, design: .monospaced))
                        .frame(width: stringNameColumnWidth, alignment: .trailing)
                    
                    ForEach(0..<numDashes, id: \.self) { col in
                        SingleCharField(text: Binding(
                            get: { model.grid[row][col] },
                            set: { newValue in
                                model.grid[row][col] = sanitizeInput(newValue)
                            }
                        ))
                            .frame(width: 12, height: 28)
                            .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.secondary, lineWidth: 0.2)
                                )
                    }
                }
            }
        }
        .padding()
    }
}


//
//#Preview {
//    TabEditorGrid()
//}
