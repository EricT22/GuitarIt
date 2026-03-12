import Foundation
import Combine

// ViewModel for the TabWriter section
class TabWriterViewModel: ObservableObject {
    @Published var tabs: [TabItem] = [];
    
    func sortedTabs(sortMode: SortMode) -> [TabItem] {
        switch sortMode {
        case .favoritesFirst:
                return tabs.sorted { // returns true if $0 should come before $1 (aka if left should go before right)
                    if ($0.isFavorite != $1.isFavorite) {
                        return $0.isFavorite && !$1.isFavorite
                    }
                    return $0.lastUsed > $1.lastUsed
                }
        case .lastUsed:
            return tabs.sorted { $0.lastUsed > $1.lastUsed }
        case .byDate:
            return tabs.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    func createNewTab() {
        // temp for now
        let placeholderURL = URL(filePath: "/dev/null");
        
        let newTab = TabItem(name: "", fileURL: placeholderURL)
        
        tabs.append(newTab)
    }
}
