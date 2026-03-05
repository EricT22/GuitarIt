import Foundation

struct TabItem: Identifiable, Hashable {
    let id = UUID()
    var isFavorite: Bool = false
    var name: String
    let createdAt: Date = Date()
    var lastUsed: Date = Date()
    
    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmed.isEmpty ? "Untitled Tab" : trimmed
    }
    
    mutating func toggleFavorite() {
        isFavorite.toggle()
    }
    
    mutating func markUsed(){
        lastUsed = Date()
    }
}
