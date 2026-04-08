import Foundation
import Combine
internal import CoreGraphics


class TabEditViewModel: ObservableObject {
    @Published var grids: [TabEditorModel] = []
    
    @Published var gridFrames: [UUID: CGRect] = [:]
    
    let fileURL: URL
    var templateName: String
    
    
    @Published var selectionMode: Bool = false
    @Published var selectedGridIDs: Set<UUID> = []
    
    
    init(tab: TabItem) {
        self.fileURL = tab.fileURL
        self.templateName = tab.templateName
    }
    
    
    func parseASCIItoGrids(_ text: String) -> [TabEditorModel] {
        let blocks = text.split(separator: "\n\n").map(String.init)
        
        return blocks.map { TabEditorModel(contentBlock: $0) }
    }
    
    func stringifyGrids(_ grids: [TabEditorModel]) -> String {
        return grids
                .map{ $0.toString() }
                .joined(separator: "\n\n")
    }
    
    
    func appendGridFromTemplate(){
        let template = TabTemplateRegistry.shared.template(named: templateName)!
        
        grids.append(TabEditorModel(stringNames: template))
    }
    
    
    
    func deleteSelectedGrids() {
        grids.removeAll { grid in
            selectedGridIDs.contains(grid.id)
        }
        
        // Selection mode still active but clears selected grids
        selectedGridIDs.removeAll()
    }
    
    
    func duplicateSelectedGrids() {
        let indices = grids.indices.filter { selectedGridIDs.contains(grids[$0].id) }
        
        // Reversed so that inserting doesn't cause shifting errors
        for index in indices.sorted().reversed() {
            let copy = grids[index].duplicate()
            
            grids.insert(copy, at: index + 1)
        }
        
        // Selection mode still active but clears selected grids
        selectedGridIDs.removeAll()
    }
    
    
    
    func toggleSelection(for id: UUID) {
        if selectedGridIDs.contains(id) {
            selectedGridIDs.remove(id)
        } else {
            selectedGridIDs.insert(id)
        }
    }
    
    
    func load() {
        do {
            let text = try String(contentsOfFile: fileURL.path(), encoding: .utf8)
            
            grids = parseASCIItoGrids(text)
        } catch {
            print("Failed to load tab contents: \(error)")
            // fallback
            grids = []
        }
    }
    
    func save() {
        let content = stringifyGrids(grids)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save tab content: \(error)")
        }
    }
}
