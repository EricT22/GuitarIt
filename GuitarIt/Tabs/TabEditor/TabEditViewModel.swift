import Foundation
import Combine


class TabEditViewModel: ObservableObject {
    @Published var grids: [TabEditorModel] = []
    
    let fileURL: URL
    var templateName: String
    
    
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
