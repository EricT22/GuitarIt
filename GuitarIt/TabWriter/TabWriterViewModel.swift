import Foundation
import Combine

// ViewModel for the TabWriter section
class TabWriterViewModel: ObservableObject {
    @Published var tabs: [TabItem] = [] {
        didSet {
            saveTabs()
        }
    }
    
    private let tabsKey: String = "tabs"
    
    
    init() {
        ensureDirectoriesExist()
        loadTabs()
    }
    
    
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
    
    func createNewTab(storage: StorageOption) {
        let directory = activeDirectory(storageOption: storage)
        
        let id = UUID()
        let fileURL = directory.appendingPathComponent("\(id.uuidString).txt")
        
        let template: String = TabTemplateRegistry.shared.standardTemplate()
        
        do {
            try template.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let newTab = TabItem(
                id: id,
                name: "",
                fileURL: fileURL
            )
            
            tabs.append(newTab)
        } catch {
            print("Failed to create new tab: \(error)")
        }
    }
    
    private func saveTabs() {
        do {
            let data = try JSONEncoder().encode(tabs)
            UserDefaults.standard.set(data, forKey: tabsKey)
        } catch {
            print("Error loading tabs: \(error)")
        }
    }
    
    private func loadTabs() {
        guard let data = UserDefaults.standard.data(forKey: tabsKey) else {
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([TabItem].self, from: data)
            tabs = decoded
        } catch {
            print("Error loading tabs: \(error)")
            
            // Reset data
            UserDefaults.standard.removeObject(forKey: tabsKey)
            tabs = []
        }
    }
    
    private func ensureDirectoriesExist() {
        let fm = FileManager.default
        
        let localDir = fm.localTabsDirectory
        
        if (!fm.fileExists(atPath: localDir.path())) {
            do {
                try fm.createDirectory(at: localDir, withIntermediateDirectories: true)
            } catch {
                print("Failed to create local directory: \(error)")
            }
        }
        
        if let iCloudDir = fm.iCloudTabsDirectory {
            if (!fm.fileExists(atPath: iCloudDir.path())){
                do {
                    try fm.createDirectory(at: iCloudDir, withIntermediateDirectories: true)
                } catch {
                    print("Failed to create iCloud directory: \(error)")
                }
            }
        }
    }
    
    private func activeDirectory(storageOption: StorageOption) -> URL {
        let fm = FileManager.default
        
        switch storageOption {
        case .local:
            return fm.localTabsDirectory
        case .cloud:
            // If iCloud isn't available just use local storage
            if let iCloudDir = fm.iCloudTabsDirectory {
                return iCloudDir
            } else {
                return fm.localTabsDirectory
            }
        }
    }
}
