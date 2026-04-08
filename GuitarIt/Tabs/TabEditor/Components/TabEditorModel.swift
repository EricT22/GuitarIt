import Foundation

struct TabEditorModel: Identifiable, Codable, Hashable {
    let id: UUID
    var stringNames: [String]
    var grid: [[String]]
    
    init(id: UUID, stringNames: [String], grid: [[String]]) {
        self.id = id
        self.stringNames = stringNames
        self.grid = grid
    }
    
    init(stringNames: [String], numDashes: Int = 22) {
        self.id = UUID()
        self.stringNames = stringNames
        self.grid = Array(repeating: Array(repeating: "-", count: numDashes),
                          count: stringNames.count)
    }
    
    // init from saved ASCII block
    init (contentBlock text: String) {
        self.id = UUID()
        
        let lines = text.split(separator: "\n").map(String.init)
                
        // Extract string names (before "|")
        self.stringNames = lines.map { line in
            String(line.prefix { $0 != "|" })
        }
        
        // Extract grid content (after "|")
        self.grid = lines.map { line in
            let afterPipe = line.split(separator: "|").last ?? ""
            return afterPipe.map { String($0) }
        }
    }
    
    
    mutating func modifyContent(_ grid: [[String]]) {
        self.grid = grid // deep copy in Swift
    }
    
    
    func duplicate() -> TabEditorModel {
        TabEditorModel(id: UUID(), stringNames: self.stringNames, grid: self.grid)
    }
    
    
    func toString() -> String {
        zip(stringNames, grid)
            .map { name, row in "\(name)|" + row.joined() }
            .joined(separator: "\n")
    }
}
