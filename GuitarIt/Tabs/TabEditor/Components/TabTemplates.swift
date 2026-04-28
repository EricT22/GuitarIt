import Foundation
import Combine

struct TabTemplate: Codable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var stringNames: [String]
    
    init (id: UUID = UUID(), name: String, stringNames: [String]) {
        self.id = id
        self.name = name
        self.stringNames = stringNames
    }
}



final class TabTemplateRegistry: ObservableObject {
    static let shared = TabTemplateRegistry()
    
    
    private let templatesKey: String = "userTemplates"
    
    private(set) var builtIn: [TabTemplate] = [
        TabTemplate(
            name: "standard",
            stringNames: ["e", "B", "G", "D", "A", "E"]
        )
    ]
    
    @Published private(set) var userTemplates: [TabTemplate] = [] {
        didSet {
            saveUserTemplates()
        }
    }
    
    var allTemplates: [TabTemplate] {
        builtIn + userTemplates
    }
    
    private init() {
        loadUserTemplates()
    }
    
    func template(named name: String) -> [String]? {
        return allTemplates.first(where: { $0.name == name })?.stringNames
    }
    
    func standardTemplate() -> [String] {
        return builtIn.first(where: { $0.name == "standard" })!.stringNames
    }
    
    func updateUserTemplates(template: TabTemplate) {
        userTemplates.append(template)
    }
    
    func deleteUserTemplate(template: TabTemplate) {
        userTemplates.removeAll(where: { $0.id == template.id })
    }
    
    private func saveUserTemplates(){
        do {
            let data = try JSONEncoder().encode(userTemplates)
            UserDefaults.standard.set(data, forKey: templatesKey)
        } catch {
            print("Error loading tabs: \(error)")
        }
    }
    
    private func loadUserTemplates() {
        guard let data = UserDefaults.standard.data(forKey: templatesKey) else {
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([TabTemplate].self, from: data)
            userTemplates = decoded
        } catch {
            print("Error loading tabs: \(error)")
            
            // Reset data
            UserDefaults.standard.removeObject(forKey: templatesKey)
            userTemplates = []
        }
    }
    
    
}
