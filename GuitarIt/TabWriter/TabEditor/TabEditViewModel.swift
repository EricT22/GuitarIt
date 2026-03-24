import Foundation
import Combine


class TabEditViewModel: ObservableObject {
    @Published var content: String = ""
    
    let fileURL: URL
    var templateName: String
    
    
    init(tab: TabItem) {
        self.fileURL = tab.fileURL
        self.templateName = tab.templateName
    }
    
    
    func appendTemplate(){
        let templateContent = TabTemplateRegistry.shared.template(named: templateName)!
        
        content += templateContent
    }
    
    
    func load() {
        do {
            let text = try String(contentsOfFile: fileURL.path(), encoding: .utf8)
            content = text
        } catch {
            print("Failed to load tab contents: \(error)")
            content = "" // fallback
        }
    }
    
    func save() {
        let cleaned = repadAllLines(in: content, toWidth: 30)
        content = cleaned
        
        do {
            try cleaned.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save tab content: \(error)")
        }
    }
}
