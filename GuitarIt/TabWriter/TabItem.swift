import Foundation

struct TabItem: Identifiable, Hashable, Codable {
    let id: UUID
    var isFavorite: Bool
    var name: String
    var templateName: String
    let createdAt: Date
    var lastUsed: Date
    
    var fileURL: URL
    
    // Computed value
    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmed.isEmpty ? "Untitled Tab" : trimmed
    }
    
    
    init (
        id: UUID = UUID(),
        isFavorite: Bool = false,
        name: String,
        templateName: String,
        createdAt: Date = Date(),
        lastUsed: Date = Date(),
        fileURL: URL
    ) {
        self.id = id
        self.isFavorite = isFavorite
        self.name = name
        self.templateName = templateName
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.fileURL = fileURL
    }
    
    
    
    mutating func toggleFavorite() {
        isFavorite.toggle()
    }
    
    mutating func markUsed(){
        lastUsed = Date()
    }
}
